import * as http from "http";
import * as restate from "@restatedev/restate-sdk";
import { initSentry, validateConfig } from "./core/config";
import { config } from "./core/config";
import { apiService } from "./services/api";
import { eventWorkflow } from "./services/workflow";
import { batchService } from "./services/batch";

validateConfig();
initSentry();

// Restate HTTP/2 endpoint on internal port (not exposed to Fly.io proxy)
const RESTATE_PORT = 9081;

const restateEndpoint = restate
  .endpoint()
  .bind(apiService)
  .bind(eventWorkflow)
  .bind(batchService);

restateEndpoint.listen(RESTATE_PORT).then(() => {
  console.log(`Restate endpoint listening on port ${RESTATE_PORT}`);
  registerDeployment();
});

async function registerDeployment() {
  const maxRetries = 30;
  for (let i = 0; i < maxRetries; i++) {
    try {
      const res = await fetch(`http://localhost:9070/deployments`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ uri: `http://localhost:${RESTATE_PORT}` }),
      });
      if (res.ok) {
        console.log("Deployment registered with Restate server.");
        return;
      }
      const text = await res.text();
      // Already registered is fine
      if (text.includes("already exists")) {
        console.log("Deployment already registered.");
        return;
      }
      console.log(`Registration attempt ${i + 1} failed (${res.status}): ${text}`);
    } catch (err) {
      console.log(`Registration attempt ${i + 1} failed: ${err}`);
    }
    await new Promise((r) => setTimeout(r, 2000));
  }
  console.error("Failed to register deployment after all retries.");
}

// HTTP/1.1 proxy server exposed to Fly.io on config.appPort
const allowedOrigins = config.corsOrigins === "*"
  ? null
  : config.corsOrigins.split(",").map((o) => o.trim());

// Map /api/* paths to Restate service handler paths
const apiRoutes: Record<string, string> = {
  "/api/event": "/ApiService/processEvent",
  "/api/event/reprocess": "/ApiService/reprocessEvent",
  "/api/event/force-reprocess": "/ApiService/forceReprocessEvent",
  "/api/events/process": "/ApiService/processBatch",
  "/api/events/process-group": "/ApiService/processGroup",
  "/api/events/list": "/ApiService/listEvents",
  "/api/courses/list": "/ApiService/listCourses",
  "/api/favorites": "/ApiService/createFavorite",
  "/api/favorites/delete": "/ApiService/deleteFavorite",
  "/api/favorites/list": "/ApiService/listFavorites",
  "/api/dance-styles/list": "/ApiService/listDanceStyles",
  "/api/event/retranslate": "/ApiService/retranslateItem",
};

// Restate server ingress port (HTTP/1.1 compatible)
const RESTATE_INGRESS_PORT = 8080;

const server = http.createServer((req, res) => {
  const origin = req.headers["origin"] as string | undefined;

  if (origin) {
    if (allowedOrigins === null || allowedOrigins.includes(origin)) {
      res.setHeader("Access-Control-Allow-Origin", origin);
    }
  } else if (allowedOrigins === null) {
    res.setHeader("Access-Control-Allow-Origin", "*");
  }

  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, x-dancee-filter, x-dancee-lang, x-dancee-include");
  res.setHeader("Access-Control-Max-Age", "86400");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  const fullUrl = req.url ?? "";
  const qIndex = fullUrl.indexOf("?");
  const pathname = qIndex >= 0 ? fullUrl.slice(0, qIndex) : fullUrl;
  const queryString = qIndex >= 0 ? fullUrl.slice(qIndex + 1) : "";
  const mappedPath = apiRoutes[pathname];

  if (!mappedPath) {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Not found" }));
    return;
  }

  const targetPath = queryString ? `${mappedPath}?${queryString}` : mappedPath;

  // Forward to Restate server ingress (port 8080) via HTTP/1.1
  const proxyReq = http.request(
    `http://localhost:8080${targetPath}`,
    { method: "POST", headers: { "content-type": "application/json" } },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode ?? 200, proxyRes.headers);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on("error", (err) => {
    res.writeHead(502, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Upstream error", details: err.message }));
  });

  // Forward all x-dancee-* headers to Restate
  for (const [key, value] of Object.entries(req.headers)) {
    if (key.startsWith("x-dancee-") && value) {
      proxyReq.setHeader(key, value as string);
    }
  }

  // Forward filter from query string as header for list endpoints
  if ((pathname === "/api/events/list" || pathname === "/api/courses/list") && queryString) {
    const params = new URLSearchParams(queryString);
    const filterParam = params.get("filter");
    if (filterParam) {
      proxyReq.setHeader("x-dancee-filter", filterParam);
    }
  }

  req.pipe(proxyReq);
});

server.listen(config.appPort, "0.0.0.0", () => {
  console.log(`HTTP proxy listening on 0.0.0.0:${config.appPort}`);
});

function shutdown(signal: string) {
  console.log(`Received ${signal}, shutting down gracefully...`);
  server.close(() => {
    console.log("Server closed.");
    process.exit(0);
  });
  setTimeout(() => {
    console.error("Graceful shutdown timed out, forcing exit.");
    process.exit(1);
  }, 10_000).unref();
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
