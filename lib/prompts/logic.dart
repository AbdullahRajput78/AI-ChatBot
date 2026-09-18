import 'package:get/get.dart';


class PromptsLogic extends GetxController {

//---------------------- list of maps of 24 items -----------------
  final List<Map<String, dynamic>> prompts = [
    {
      'name': 'Design',
      'emoji': '\u{270D}\u{FE0F}',
      'prompts': [
        'Design a modern logo for my brand',
        'Design a color palette for a website',
        'Design a poster for a music event',
      ],
    },
    {
      'name': 'Email',
      'emoji': '\u{1F48C}',
      'prompts': [
        'Write a professional follow-up email',
        'Draft a resignation email',
        'Write a cold outreach email to a client',
      ],
    },
    {
      'name': 'Sales',
      'emoji': '\u{1F3F7}\u{FE0F}',
      'prompts': [
        'Write a sales pitch for my product',
        'Create a discount offer announcement',
        'Draft a follow-up message for a lead',
      ],
    },
    {
      'name': 'Fashion',
      'emoji': '\u{1F457}',
      'prompts': [
        'Suggest an outfit for a summer wedding',
        'Describe the latest fashion trends',
        'Create a capsule wardrobe plan',
      ],
    },
    {
      'name': 'Marketing',
      'emoji': '\u{1F680}',
      'prompts': [
        'Create a marketing strategy for a startup',
        'Write a social media campaign idea',
        'Draft an ad copy for Instagram',
      ],
    },
    {
      'name': '3D Art',
      'emoji': '\u{1F3A8}',
      'prompts': [
        'Describe a 3D character concept',
        'Explain how to model a low-poly tree',
        'Suggest a 3D scene for a sci-fi game',
      ],
    },
    {
      'name': 'Travel',
      'emoji': '\u{2708}\u{FE0F}',
      'prompts': [
        'Plan a 5-day trip to Japan',
        'Suggest budget travel tips for Europe',
        'Create a packing checklist for a beach trip',
      ],
    },
    {
      'name': 'History',
      'emoji': '\u{1F3F0}',
      'prompts': [
        'Explain the fall of the Roman Empire',
        'Summarize the causes of World War I',
        'Describe daily life in ancient Egypt',
      ],
    },
    {
      'name': 'Media',
      'emoji': '\u{1F3A5}',
      'prompts': [
        'Write a short film script idea',
        'Create a YouTube video title and description',
        'Draft a press release for a media event',
      ],
    },
    {
      'name': 'Sing',
      'emoji': '\u{1F3A4}',
      'prompts': [
        'Write lyrics for a pop song',
        'Suggest vocal warm-up exercises',
        'Create a setlist for a concert',
      ],
    },
    {
      'name': 'Recipe',
      'emoji': '\u{1F468}\u{200D}\u{1F373}',
      'prompts': [
        'Give me a recipe for chicken biryani',
        'Suggest a quick 15-minute breakfast recipe',
        'Create a dessert recipe using mangoes',
      ],
    },
    {
      'name': 'Growth',
      'emoji': '\u{1F4C8}',
      'prompts': [
        'Suggest strategies to grow my Instagram',
        'Explain how to improve productivity daily',
        'Create a personal growth plan for this year',
      ],
    },
    {
      'name': 'Study',
      'emoji': '\u{1F393}',
      'prompts': [
        'Create a study schedule for exams',
        'Explain the Pomodoro technique',
        'Summarize this topic for quick revision',
      ],
    },
    {
      'name': 'Hobbies',
      'emoji': '\u{1F6B4}',
      'prompts': [
        'Suggest a new hobby to try this month',
        'Give tips for starting photography',
        'Recommend indoor hobbies for winter',
      ],
    },
    {
      'name': 'Lawyer',
      'emoji': '\u{2696}\u{FE0F}',
      'prompts': [
        'Explain the basics of contract law',
        'Draft a simple non-disclosure agreement',
        'Explain tenant rights in a rental dispute',
      ],
    },
    {
      'name': 'Science',
      'emoji': '\u{1F52C}',
      'prompts': [
        'Explain how black holes are formed',
        'Describe the process of photosynthesis',
        'Explain quantum entanglement simply',
      ],
    },
    {
      'name': 'Relation',
      'emoji': '\u{1F91D}',
      'prompts': [
        'Give advice for resolving a conflict with a friend',
        'Suggest ways to improve communication in a relationship',
        'Write a heartfelt apology message',
      ],
    },
    {
      'name': 'Language',
      'emoji': '\u{1F4AC}',
      'prompts': [
        'Teach me 10 common Spanish phrases',
        'Explain the difference between affect and effect',
        'Help me practice conversational French',
      ],
    },
    {
      'name': 'Tech',
      'emoji': '\u{1F916}',
      'prompts': [
        'Explain how machine learning works',
        'Suggest the best programming language to learn first',
        'Explain the difference between AI and AGI',
      ],
    },
    {
      'name': 'Business',
      'emoji': '\u{1F4BC}',
      'prompts': [
        'Create a business plan for a small startup',
        'Suggest ways to reduce operational costs',
        'Write a pitch for investors',
      ],
    },
    {
      'name': 'Spirituality',
      'emoji': '\u{1F9D8}',
      'prompts': [
        'Explain the concept of mindfulness',
        'Suggest a daily meditation routine',
        'Describe the meaning of inner peace',
      ],
    },
    {
      'name': 'Enjoy',
      'emoji': '\u{1F3AD}',
      'prompts': [
        'Suggest fun weekend activities',
        'Recommend a movie based on my mood',
        'Give me a game to play with friends',
      ],
    },
    {
      'name': 'Zodiac',
      'emoji': '\u{1F52E}',
      'prompts': [
        'Explain my zodiac sign traits',
        'Give a horoscope reading for today',
        'Explain compatibility between two zodiac signs',
      ],
    },
    {
      'name': 'Finance',
      'emoji': '\u{1F4B0}',
      'prompts': [
        'Create a monthly budget plan',
        'Explain how compound interest works',
        'Suggest beginner tips for investing',
      ],
    },
  ];
}
