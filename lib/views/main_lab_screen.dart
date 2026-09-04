import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/circuit_parameters.dart';
import '../widgets/status_badge.dart';
import 'simulation/circuit_workbench_view.dart';
import 'graphs/interactive_graphs_view.dart';
import 'observation_table/observation_table_view.dart';
import 'manual/lab_manual_view.dart';

class MainLabScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainLabScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainLabScreen> createState() => _MainLabScreenState();
}

class _MainLabScreenState extends State<MainLabScreen> {
  final LabController _controller = LabController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0E1726) : const Color(0xFF0284C7),
            titleSpacing: 20,
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Zener Diode Voltage Regulator',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Interactive Virtual Laboratory Workbench',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Active State Badge
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: StatusBadge(
                  status: _controller.result.status,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),

              // Theme Mode Toggle
              IconButton(
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: widget.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                onPressed: widget.onToggleTheme,
              ),

              // Reset Circuit Button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                tooltip: 'Reset to Standard Parameters',
                onPressed: () {
                  _controller.updateParameters(const CircuitParameters());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Circuit reset to default parameters (Vin=15V, Vz=5.1V, Rs=220Ω, RL=1kΩ).'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Info / Help Dialog
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                tooltip: 'About Virtual Lab',
                onPressed: () => _showAboutDialog(context, isDark),
              ),
              const SizedBox(width: 12),
            ],
          ),

          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 940;

              if (isDesktop) {
                // Desktop Layout with Navigation Rail
                return Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedTabIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedTabIndex = index);
                      },
                      minWidth: 80,
                      labelType: NavigationRailLabelType.all,
                      backgroundColor:
                          isDark ? const Color(0xFF0E1726) : const Color(0xFFF1F5F9),
                      indicatorColor:
                          isDark ? const Color(0xFF0284C7).withOpacity(0.25) : const Color(0xFFE0F2FE),
                      selectedIconTheme:
                          const IconThemeData(color: Color(0xFF38BDF8), size: 24),
                      unselectedIconTheme:
                          IconThemeData(color: isDark ? Colors.white60 : Colors.black54, size: 22),
                      selectedLabelTextStyle: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                      unselectedLabelTextStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.developer_board_outlined),
                          selectedIcon: Icon(Icons.developer_board_rounded),
                          label: Text('Workbench'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.show_chart_rounded),
                          selectedIcon: Icon(Icons.show_chart_rounded),
                          label: Text('Graphs'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.table_chart_outlined),
                          selectedIcon: Icon(Icons.table_chart_rounded),
                          label: Text('Observations'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.menu_book_outlined),
                          selectedIcon: Icon(Icons.menu_book_rounded),
                          label: Text('Lab Manual'),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                    Expanded(child: _buildSelectedTabContent()),
                  ],
                );
              } else {
                // Mobile / Compact Layout
                return _buildSelectedTabContent();
              }
            },
          ),

          bottomNavigationBar: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 940) {
                return const SizedBox.shrink();
              }
              return NavigationBar(
                selectedIndex: _selectedTabIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                backgroundColor:
                    isDark ? const Color(0xFF0E1726) : const Color(0xFFF8FAFC),
                indicatorColor:
                    isDark ? const Color(0xFF0284C7).withOpacity(0.3) : const Color(0xFFE0F2FE),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.developer_board_outlined),
                    selectedIcon: Icon(Icons.developer_board_rounded),
                    label: 'Workbench',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.show_chart_rounded),
                    selectedIcon: Icon(Icons.show_chart_rounded),
                    label: 'Graphs',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.table_chart_outlined),
                    selectedIcon: Icon(Icons.table_chart_rounded),
                    label: 'Observations',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'Lab Manual',
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return CircuitWorkbenchView(controller: _controller);
      case 1:
        return InteractiveGraphsView(controller: _controller);
      case 2:
        return ObservationTableView(controller: _controller);
      case 3:
        return LabManualView(controller: _controller);
      default:
        return CircuitWorkbenchView(controller: _controller);
    }
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFF38BDF8), size: 22),
            SizedBox(width: 8),
            Text(
              'Zener Diode Virtual Lab',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'An interactive virtual simulation designed for undergraduate electronics and electrical engineering students.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 14),
              Text(
                'Key Capabilities:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                '• Real-time Thevenin DC circuit solver with dynamic animated current flow.\n'
                '• Automatic visual alerts for breakdown dropout, overpower burnout, and knee current.\n'
                '• Interactive Line Regulation, Load Regulation, and Zener I-V curves.\n'
                '• Observation table data logger with % Line & Load Regulation calculation and CSV export.\n'
                '• Lab Manual with theory, equations, step-by-step procedures, and viva-voce quiz.',
                style: TextStyle(fontSize: 12, height: 1.55),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
