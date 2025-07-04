import 'package:flutter/material.dart';

class FancyCard extends StatefulWidget {
  const FancyCard({super.key});

  @override
  State<FancyCard> createState() => _FancyCardState();
}

class _FancyCardState extends State<FancyCard> with SingleTickerProviderStateMixin {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const cardAccent = Color(0xFF7C3AED);
    const cardText = Color(0xFF1E293B);

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          width: 190,
          height: 254,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hovering
                ? [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 25,
                offset: const Offset(0, 15),
              )
            ]
                : [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(
              color: _hovering ? cardAccent.withOpacity(0.2) : Colors.white24,
            ),
          ),
          child: Stack(
            children: [
              // Shine effect (simplified)
              if (_hovering)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white54,
                            Colors.transparent,
                          ],
                          begin: Alignment(-1.0, -0.5),
                          end: Alignment(1.0, 0.5),
                          stops: [0.4, 0.5, 0.6],
                        ),
                      ),
                    ),
                  ),
                ),

              // Glow effect (simplified)
              if (_hovering)
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -1),
                        colors: [
                          cardAccent.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        radius: 1,
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    AnimatedScale(
                      scale: _hovering ? 1 : 0.8,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _hovering ? 1 : 0,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Image area
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: _hovering
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ]
                            : [],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _hovering ? cardAccent : cardText,
                          ),
                          duration: const Duration(milliseconds: 300),
                          child: const Text("Premium Design"),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _hovering ? 1.0 : 0.7,
                          child: Text(
                            "Hover to reveal stunning effects",
                            style: TextStyle(
                              fontSize: 12,
                              color: cardText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _hovering ? cardAccent : cardText,
                            fontSize: 14,
                          ),
                          child: const Text("\$49.99"),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: cardAccent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: _hovering
                                ? [
                              BoxShadow(
                                color: cardAccent.withOpacity(0.2),
                                spreadRadius: 4,
                              )
                            ]
                                : [],
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
