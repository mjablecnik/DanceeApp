import { describe, it, expect, vi, beforeEach } from "vitest";

// --- Mock all side-effectful dependencies before importing index.ts ---

vi.mock("../core/config", () => ({
  config: {
    corsOrigins: "*",
    appPort: 9080,
    internalApiKey: "test-api-key",
  },
  validateConfig: vi.fn(),
  initSentry: vi.fn(),
  captureError: vi.fn(),
}));

// Capture the HTTP request handler from http.createServer
let capturedHandler: (
  req: Record<string, unknown>,
  res: Record<string, unknown>
) => void;

// Track http.request calls to verify proxy routing
const mockProxyReq = {
  on: vi.fn().mockReturnThis(),
  setHeader: vi.fn(),
  end: vi.fn(),
  pipe: vi.fn(),
};

const mockHttpRequest = vi.fn(() => mockProxyReq);

vi.mock("http", () => ({
  createServer: vi.fn((handler) => {
    capturedHandler = handler;
    return { listen: vi.fn() };
  }),
  request: (...args: unknown[]) => mockHttpRequest(...args),
}));

// Mock Restate SDK — just need a stub that exposes listen
vi.mock("@restatedev/restate-sdk", () => ({
  endpoint: vi.fn(() => ({
    bind: vi.fn().mockReturnThis(),
    listen: vi.fn().mockResolvedValue(undefined),
  })),
  workflow: (def: unknown) => def,
  service: (def: unknown) => def,
}));

// Mock all services so they don't execute real logic
vi.mock("../services/api", () => ({ apiService: {} }));
vi.mock("../services/workflow", () => ({ eventWorkflow: {} }));
vi.mock("../services/batch", () => ({ batchService: {} }));

// Import index.ts after mocks — this triggers server setup and captures the handler
await import("../index");

// Helper: build a minimal mock request/response pair
function makeMockReqRes(overrides: {
  method?: string;
  url?: string;
  origin?: string;
  authorization?: string;
} = {}) {
  const { method = "GET", url = "/api/events/list", origin, authorization } = overrides;
  const headers: Record<string, string | undefined> = {};
  if (origin) headers["origin"] = origin;
  if (authorization) headers["authorization"] = authorization;

  const setHeaderCalls: Array<[string, string]> = [];
  const res = {
    setHeader: vi.fn((name: string, value: string) => {
      setHeaderCalls.push([name, value]);
    }),
    writeHead: vi.fn(),
    end: vi.fn(),
    _headers: setHeaderCalls,
  };

  const req = {
    method,
    url,
    headers,
    pipe: vi.fn(),
  };

  return { req, res };
}

beforeEach(() => {
  vi.clearAllMocks();
  // Reset mockProxyReq mock state
  mockProxyReq.on.mockReturnThis();
});

describe("index.ts: route mapping", () => {
  it("maps /api/event to /ApiService/processEvent via proxy to port 8080", () => {
    const { req, res } = makeMockReqRes({ method: "POST", url: "/api/event", authorization: "Bearer test-api-key" });
    capturedHandler(req, res);
    const firstCall = mockHttpRequest.mock.calls[0];
    expect(firstCall[0]).toContain("/ApiService/processEvent");
    expect(firstCall[0]).toContain("localhost:8080");
  });

  it("maps /api/events/process to /ApiService/processBatch", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/process", authorization: "Bearer test-api-key" });
    capturedHandler(req, res);
    const firstCall = mockHttpRequest.mock.calls[0];
    expect(firstCall[0]).toContain("/ApiService/processBatch");
  });

  it("returns 401 for privileged routes without a valid API key", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/process" });
    capturedHandler(req, res);
    expect(res.writeHead).toHaveBeenCalledWith(401, expect.objectContaining({ "Content-Type": "application/json" }));
    expect(mockHttpRequest).not.toHaveBeenCalled();
  });

  it("maps /api/events/list to /ApiService/listEvents", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const firstCall = mockHttpRequest.mock.calls[0];
    expect(firstCall[0]).toContain("/ApiService/listEvents");
  });

  it("returns 404 for unmapped paths instead of proxying to admin port", () => {
    const { req, res } = makeMockReqRes({ url: "/restate/health" });
    capturedHandler(req, res);
    expect(res.writeHead).toHaveBeenCalledWith(404, expect.objectContaining({ "Content-Type": "application/json" }));
    expect(mockHttpRequest).not.toHaveBeenCalled();
  });

  it("preserves query string when mapping routes", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list?filter=%7B%7D" });
    capturedHandler(req, res);
    const firstCall = mockHttpRequest.mock.calls[0];
    expect(firstCall[0]).toContain("/ApiService/listEvents?filter=%7B%7D");
  });
});

describe("index.ts: CORS headers", () => {
  it("sets Access-Control-Allow-Methods and Access-Control-Allow-Headers on all requests", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Methods"]).toBeDefined();
    expect(headerMap["Access-Control-Allow-Headers"]).toBeDefined();
  });

  it("sets Access-Control-Allow-Origin: * when no origin header and corsOrigins is *", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Origin"]).toBe("*");
  });

  it("echoes back request origin in Access-Control-Allow-Origin when corsOrigins is *", () => {
    const { req, res } = makeMockReqRes({
      url: "/api/events/list",
      origin: "https://app.example.com",
    });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Origin"]).toBe("https://app.example.com");
  });
});

describe("index.ts: OPTIONS preflight handling", () => {
  it("responds with 204 and does not proxy for OPTIONS requests", () => {
    const { req, res } = makeMockReqRes({ method: "OPTIONS", url: "/api/event" });
    const requestCallsBefore = mockHttpRequest.mock.calls.length;
    capturedHandler(req, res);
    expect(res.writeHead).toHaveBeenCalledWith(204);
    expect(res.end).toHaveBeenCalled();
    // http.request must NOT be called for preflight
    expect(mockHttpRequest.mock.calls.length).toBe(requestCallsBefore);
  });
});

describe("index.ts: filter query parameter forwarding", () => {
  it("forwards filter query param as x-dancee-filter header on the proxy request for /api/events/list", () => {
    const filter = JSON.stringify({ category: { _eq: "dance" } });
    const encoded = encodeURIComponent(filter);
    const { req, res } = makeMockReqRes({
      url: `/api/events/list?filter=${encoded}`,
    });
    capturedHandler(req, res);
    // x-dancee-filter is set on the proxy request (proxyReq), not on req
    const setHeaderCalls = mockProxyReq.setHeader.mock.calls as [string, string][];
    const filterHeader = setHeaderCalls.find(([name]) => name === "x-dancee-filter");
    expect(filterHeader).toBeDefined();
    expect(filterHeader![1]).toBe(filter);
  });

  it("does not set x-dancee-filter for non-list routes", () => {
    const { req, res } = makeMockReqRes({
      url: "/api/events/process?filter=something",
    });
    capturedHandler(req, res);
    const setHeaderCalls = mockProxyReq.setHeader.mock.calls as [string, string][];
    const filterHeader = setHeaderCalls.find(([name]) => name === "x-dancee-filter");
    expect(filterHeader).toBeUndefined();
  });

  it("does not set x-dancee-filter when no filter param is present", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const setHeaderCalls = mockProxyReq.setHeader.mock.calls as [string, string][];
    const filterHeader = setHeaderCalls.find(([name]) => name === "x-dancee-filter");
    expect(filterHeader).toBeUndefined();
  });
});
