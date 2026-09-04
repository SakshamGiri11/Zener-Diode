class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.topic,
  });

  static const List<QuizQuestion> defaultQuestions = [
    QuizQuestion(
      id: 1,
      topic: 'Operating Bias',
      question: 'In which region does a Zener diode operate when used as a voltage regulator?',
      options: [
        'Forward active bias region',
        'Reverse breakdown region',
        'Reverse unbiased / cutoff region',
        'Saturation region',
      ],
      correctOptionIndex: 1,
      explanation:
          r'A Zener diode regulates voltage by operating in its reverse breakdown region, where the voltage across it remains nearly constant ($V_z$) despite large changes in reverse current ($I_z$).',
    ),
    QuizQuestion(
      id: 2,
      topic: 'Breakdown Physics',
      question:
          'Which breakdown mechanism predominantly occurs in Zener diodes with breakdown voltages below 5.6V?',
      options: [
        'Avalanche breakdown due to impact ionization',
        'Zener breakdown due to quantum mechanical tunneling in heavily doped junctions',
        'Thermal runaway breakdown',
        'Dielectric rupture',
      ],
      correctOptionIndex: 1,
      explanation:
          r'Heavily doped p-n junctions have very thin depletion regions (< 10 nm). High electric fields (~10^6 V/m) pull valence electrons directly across the barrier (quantum tunneling), creating Zener breakdown with a negative temperature coefficient.',
    ),
    QuizQuestion(
      id: 3,
      topic: 'Regulation Condition',
      question: 'What is the fundamental condition required across the load for regulation to hold?',
      options: [
        r'Thevenin open-circuit voltage $V_{th} \ge V_z$',
        r'Load resistance $R_L < R_s$',
        r'Input voltage $V_{in} \le V_z$',
        r'Zener current $I_z = 0$',
      ],
      correctOptionIndex: 0,
      explanation:
          r'For the Zener diode to conduct in the breakdown region, the open-circuit voltage across the diode terminals $V_{th} = V_{in} \cdot \frac{R_L}{R_s + R_L}$ must be greater than or equal to $V_z$. Otherwise, the diode stays OFF.',
    ),
    QuizQuestion(
      id: 4,
      topic: 'Series Resistor Role',
      question: r'What is the primary function of the series resistor ($R_s$) in a Zener regulator circuit?',
      options: [
        'To amplify the output voltage',
        r'To limit the Zener current and absorb fluctuations in $V_{in}$',
        'To provide high-pass filtering',
        r'To increase the load current $I_L$',
      ],
      correctOptionIndex: 1,
      explanation:
          r'The series resistor $R_s$ limits the total current drawn from the source, protecting the Zener diode from burning out, and absorbs any fluctuations in $V_{in}$ via the drop $V_{Rs} = V_{in} - V_z$.',
    ),
    QuizQuestion(
      id: 5,
      topic: 'No-Load Condition',
      question: r'What happens to the Zener current ($I_z$) when the load resistor ($R_L$) is disconnected (open circuit)?',
      options: [
        'Zener current drops to zero',
        r'Zener current increases to its maximum ($I_z = I_s$)',
        'Zener diode immediately switches to forward bias',
        'Input current drops to zero',
      ],
      correctOptionIndex: 1,
      explanation:
          r'Since $I_s = I_z + I_L$, when $R_L$ is open-circuited ($I_L = 0$), all source current flows entirely through the Zener diode ($I_z = I_s$). This is the maximum power dissipation condition for the Zener diode.',
    ),
    QuizQuestion(
      id: 6,
      topic: 'Line vs Load Regulation',
      question: 'How is percentage line regulation mathematically defined?',
      options: [
        r'$\frac{\Delta V_L}{\Delta V_{in}} \times 100\%$ (at constant $R_L$)',
        r'$\frac{V_{NL} - V_{FL}}{V_{FL}} \times 100\%$ (at constant $V_{in}$)',
        r'$\frac{I_z}{I_L} \times 100\%$',
        r'$\frac{P_z}{P_{in}} \times 100\%$',
      ],
      correctOptionIndex: 0,
      explanation:
          r'Line regulation measures the change in regulated output voltage ($\Delta V_L$) resulting from a specified change in unregulated input voltage ($\Delta V_{in}$) at constant load.',
    ),
    QuizQuestion(
      id: 7,
      topic: r'Knee Current ($I_{zk}$)',
      question: r'What is the significance of the Zener Knee Current ($I_{zk}$)?',
      options: [
        'It is the maximum destructive current the diode can withstand',
        'It is the minimum reverse current required to enter and sustain the stable breakdown region',
        'It is the forward turn-on threshold current',
        'It is the leakage current when reverse voltage is zero',
      ],
      correctOptionIndex: 1,
      explanation:
          r'The knee current $I_{zk}$ is the minimum operating current below which the dynamic resistance increases sharply and voltage regulation degrades noticeably.',
    ),
    QuizQuestion(
      id: 8,
      topic: 'Thermal Rating',
      question: r'If a 10V Zener diode has a maximum power rating of 0.5 W, what is its maximum safe current $I_{z,\max}$?',
      options: [
        '5 mA',
        '50 mA',
        '500 mA',
        '5 A',
      ],
      correctOptionIndex: 1,
      explanation:
          r'$I_{z,\max} = \frac{P_{z,\max}}{V_z} = \frac{0.5\text{ W}}{10\text{ V}} = 0.05\text{ A} = 50\text{ mA}$. Operating beyond this causes excessive thermal dissipation.',
    ),
  ];
}
