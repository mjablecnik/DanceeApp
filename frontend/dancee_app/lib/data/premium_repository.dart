// ─── Model classes ───────────────────────────────────────────────────────────

class PremiumFeatureData {
  final String title;
  final String description;

  const PremiumFeatureData({required this.title, required this.description});
}

class PremiumPlanData {
  final String title;
  final String subtitle;
  final String price;
  final String? originalPrice;
  final String note;
  final String ctaLabel;
  final String? badge;
  final bool isPrimary;

  const PremiumPlanData({
    required this.title,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    required this.note,
    required this.ctaLabel,
    this.badge,
    required this.isPrimary,
  });
}

class TestimonialData {
  final String avatarUrl;
  final String name;
  final String quote;

  const TestimonialData({
    required this.avatarUrl,
    required this.name,
    required this.quote,
  });
}

class FaqData {
  final String question;
  final String answer;

  const FaqData({required this.question, required this.answer});
}

// ─── Repository ───────────────────────────────────────────────────────────────

class PremiumRepository {
  const PremiumRepository();

  Future<List<PremiumFeatureData>> getFeatures() async {
    return const [
      PremiumFeatureData(
        title: 'Neomezené oblíbené akce',
        description: 'Ukládejte si neomezený počet tanečních akcí',
      ),
      PremiumFeatureData(
        title: 'Pokročilé filtry',
        description: 'Filtrujte podle více kritérií najednou',
      ),
      PremiumFeatureData(
        title: 'Upozornění na nové akce',
        description: 'Buďte první, kdo se dozví o nových eventtech',
      ),
      PremiumFeatureData(
        title: 'Offline režim',
        description: 'Přístup k uloženým akcím bez internetu',
      ),
      PremiumFeatureData(
        title: 'Prioritní podpora',
        description: 'Rychlejší odpovědi na vaše dotazy',
      ),
      PremiumFeatureData(
        title: 'Žádné reklamy',
        description: 'Užívejte si aplikaci bez přerušení',
      ),
      PremiumFeatureData(
        title: 'Exkluzivní odznaky',
        description: 'Speciální odznaky na vašem profilu',
      ),
      PremiumFeatureData(
        title: 'Kalendářová integrace',
        description: 'Synchronizace s vaším kalendářem',
      ),
    ];
  }

  Future<List<PremiumPlanData>> getPlans() async {
    return const [
      PremiumPlanData(
        title: 'Roční předplatné',
        subtitle: 'Nejlepší hodnota',
        price: '499 Kč',
        originalPrice: '999 Kč',
        note: 'Pouze 42 Kč/měsíc · Ušetříte 50%',
        ctaLabel: 'Vybrat roční plán',
        badge: 'POPULÁRNÍ',
        isPrimary: true,
      ),
      PremiumPlanData(
        title: 'Měsíční předplatné',
        subtitle: 'Flexibilní možnost',
        price: '99 Kč',
        note: 'Fakturováno měsíčně',
        ctaLabel: 'Vybrat měsíční plán',
        isPrimary: false,
      ),
    ];
  }

  Future<List<TestimonialData>> getTestimonials() async {
    return const [
      TestimonialData(
        avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-2.jpg',
        name: 'Martin Dvořák',
        quote: '"Premium předplatné mi úplně změnilo způsob, jak objevuji taneční akce. Upozornění jsou skvělá!"',
      ),
      TestimonialData(
        avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
        name: 'Jana Svobodová',
        quote: '"Nejlepší investice pro tanečníka! Pokročilé filtry mi ušetřily spoustu času."',
      ),
    ];
  }

  Future<List<FaqData>> getFaqs() async {
    return const [
      FaqData(
        question: 'Mohu předplatné kdykoliv zrušit?',
        answer: 'Ano, předplatné můžete zrušit kdykoliv. Přístup k Premium funkcím vám zůstane až do konce zaplaceného období.',
      ),
      FaqData(
        question: 'Jaké platební metody přijímáte?',
        answer: 'Přijímáme platební karty (Visa, Mastercard), Apple Pay, Google Pay a bankovní převody.',
      ),
      FaqData(
        question: 'Nabízíte zkušební období?',
        answer: 'Ano! Nový uživatelé získají 7 dní Premium zdarma. Můžete zrušit kdykoliv během zkušebního období.',
      ),
      FaqData(
        question: 'Co se stane s mými daty po zrušení?',
        answer: 'Všechna vaše data zůstanou zachována. Ztratíte pouze přístup k Premium funkcím, ale základní funkce aplikace budou stále dostupné.',
      ),
    ];
  }
}
