import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../l10n/static_translations.dart';
import '../providers/expense_provider.dart';
import '../utils/csv_exporter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _selectedCategory;

  final double _targetAmount = 200000.0;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);

    final filteredList = expenseProvider.getFilteredExpenses(_selectedYear, _selectedMonth);
    final monthlyTotal = expenseProvider.getTotalForList(filteredList);
    
    final categoryData = expenseProvider.getCategorySplit(filteredList);
    categoryData.removeWhere((key, value) => value <= 0);
    
    if (_selectedCategory == null && categoryData.isNotEmpty) {
      _selectedCategory = categoryData.keys.first;
    } else if (categoryData.isNotEmpty && !categoryData.containsKey(_selectedCategory)) {
      _selectedCategory = categoryData.keys.first;
    } else if (categoryData.isEmpty) {
      _selectedCategory = null;
    }

    final subCategoryData = _selectedCategory != null 
        ? expenseProvider.getSubCategorySplit(filteredList, _selectedCategory!) 
        : <String, double>{};
    subCategoryData.removeWhere((key, value) => value <= 0);

    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.amber,
      Colors.pink, Colors.indigo, Colors.brown, Colors.cyan
    ];

    List<PieChartSectionData> getCategorySections() {
      if (categoryData.isEmpty) {
        return [PieChartSectionData(color: Colors.grey.shade300, value: 1, title: '')];
      }
      int i = 0;
      return categoryData.entries.map((entry) {
        final percentage = (entry.value / monthlyTotal) * 100;
        final isSelected = entry.key == _selectedCategory;
        final titleStr = percentage.round() == 0 ? '' : '${percentage.toStringAsFixed(0)}%';
        final section = PieChartSectionData(
          color: colors[i % colors.length],
          value: entry.value,
          title: titleStr,
          radius: isSelected ? 45 : 35,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        );
        i++;
        return section;
      }).toList();
    }

    List<PieChartSectionData> getSubCategorySections() {
      if (subCategoryData.isEmpty) {
        return [PieChartSectionData(color: Colors.grey.shade300, value: 1, title: '')];
      }
      int i = 0;
      final totalSub = subCategoryData.values.fold(0.0, (a, b) => a + b);
      return subCategoryData.entries.map((entry) {
        final percentage = (entry.value / totalSub) * 100;
        final titleStr = percentage.round() == 0 ? '' : '${percentage.toStringAsFixed(0)}%\n${entry.key}';
        final section = PieChartSectionData(
          color: colors[(i + 3) % colors.length],
          value: entry.value,
          title: titleStr,
          radius: 35,
          titleStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
        );
        i++;
        return section;
      }).toList();
    }

    final dailyTrend = expenseProvider.getDailyTrend(_selectedYear, _selectedMonth);
    final past6Months = expenseProvider.getPast6MonthsAggregate(_selectedYear, _selectedMonth);
    final memberData = expenseProvider.getMemberWiseSplit(filteredList);

    Widget buildFilter() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<int>(
            value: _selectedMonth,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(DateFormat('MMMM').format(DateTime(2000, index + 1))),
              );
            }),
            onChanged: (val) {
              if (val != null) setState(() => _selectedMonth = val);
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: _selectedYear,
            items: List.generate(10, (index) {
              int year = DateTime.now().year - 5 + index;
              return DropdownMenuItem(value: year, child: Text(year.toString()));
            }),
            onChanged: (val) {
              if (val != null) setState(() => _selectedYear = val);
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(StaticTranslations.get(context, 'dashboardTab'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildFilter(),
            const SizedBox(height: 16),
            
            // Monthly Aggregate
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'monthlyAggregate'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${monthlyTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Trend Line Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'monthlyTrend'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => theme.colorScheme.onSurface,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  return LineTooltipItem(
                                    spot.y.toStringAsFixed(0),
                                    TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                getTitlesWidget: (value, meta) {
                                  final dates = dailyTrend.keys.toList();
                                  if (value.toInt() >= 0 && value.toInt() < dates.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('${dates[value.toInt()].day}', style: const TextStyle(fontSize: 10)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: dailyTrend.values.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Semi Circular Gauge Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'monthlyTargetProgress'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140, // Reduced height because it's a half-circle
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Clip the bottom half off the PieChart using Align & heightFactor
                          Align(
                            alignment: Alignment.topCenter,
                            heightFactor: 0.5,
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: 180,
                                sectionsSpace: 0,
                                centerSpaceRadius: 60,
                                sections: [
                                  // Green section for up to 100% of target
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: monthlyTotal > _targetAmount ? _targetAmount : monthlyTotal,
                                    title: '',
                                    radius: 20,
                                  ),
                                  // Red section for amount exceeding target
                                  if (monthlyTotal > _targetAmount)
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: monthlyTotal - _targetAmount,
                                      title: '',
                                      radius: 20,
                                    ),
                                  // Grey section for remaining target
                                  if (monthlyTotal < _targetAmount)
                                    PieChartSectionData(
                                      color: Colors.grey.shade200,
                                      value: _targetAmount - monthlyTotal,
                                      title: '',
                                      radius: 20,
                                    ),
                                  // Dummy section for the bottom half
                                  PieChartSectionData(
                                    color: Colors.transparent,
                                    value: monthlyTotal > _targetAmount ? monthlyTotal : _targetAmount,
                                    title: '',
                                    radius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${((monthlyTotal / _targetAmount) * 100).toStringAsFixed(1)}%', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                Text('${StaticTranslations.get(context, 'ofTarget')} ₹${_targetAmount.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expenses by Category (Side-by-side pie charts)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'expensesByCategory'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Pie Chart
                        Expanded(
                          child: SizedBox(
                            height: 160,
                            child: PieChart(
                              PieChartData(
                                sections: getCategorySections(),
                                centerSpaceRadius: 25,
                                sectionsSpace: 2,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                      return;
                                    }
                                    final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    if (touchedIndex >= 0 && touchedIndex < categoryData.keys.length) {
                                      setState(() {
                                        _selectedCategory = categoryData.keys.elementAt(touchedIndex);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sub Category Pie Chart & Dropdown
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (categoryData.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      items: categoryData.keys.map((cat) {
                                        return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCategory = val);
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: PieChart(
                                  PieChartData(
                                    sections: getSubCategorySections(),
                                    centerSpaceRadius: 15,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bar chart: Member wise expense
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'memberWiseExpense'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    
                    SizedBox(
                      height: 180,
                      child: memberData.isEmpty 
                        ? Center(child: Text(StaticTranslations.get(context, 'noData'), style: const TextStyle(color: Colors.grey)))
                        : BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => theme.colorScheme.onSurface,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  rod.toY.toStringAsFixed(0),
                                  TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final keys = memberData.keys.toList();
                                  if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: memberData.entries.toList().asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.value,
                                  color: theme.colorScheme.tertiary,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Line chart: Past 6 months
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(StaticTranslations.get(context, 'past6Months'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => theme.colorScheme.onSurface,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  return LineTooltipItem(
                                    spot.y.toStringAsFixed(0),
                                    TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final keys = past6Months.keys.toList();
                                  if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                    final parts = keys[value.toInt()].split('-');
                                    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(DateFormat('MMM').format(dt), style: const TextStyle(fontSize: 10)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: past6Months.values.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: theme.colorScheme.secondary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () => CSVExporter.exportToCSV(context, expenseProvider.expenses),
              icon: const Icon(Icons.download),
              label: Text(StaticTranslations.get(context, 'exportCSV')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
