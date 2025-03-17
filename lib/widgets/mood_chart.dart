import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/app_theme.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final int daysToShow;

  const MoodChart({
    Key? key,
    required this.entries,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('Sem dados suficientes para gerar o gráfico'),
      );
    }

    // Organizando entradas por data
    final sortedEntries = List<MoodEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Filtrando apenas os últimos X dias
    final now = DateTime.now();
    final cutoffDate = DateTime(now.year, now.month, now.day - daysToShow);
    final filteredEntries = sortedEntries
        .where((entry) => entry.date.isAfter(cutoffDate))
        .toList();

    // Se não houver entradas nos últimos X dias
    if (filteredEntries.isEmpty) {
      return const Center(
        child: Text('Sem entradas nos últimos dias'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolução do Humor',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Últimos $daysToShow dias',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              mainChart(filteredEntries),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Muito Feliz', 5, AppTheme.happyColor),
        const SizedBox(width: 16),
        _legendItem('Neutro', 3, AppTheme.calmColor),
        const SizedBox(width: 16),
        _legendItem('Muito Triste', 1, AppTheme.sadColor),
      ],
    );
  }

  Widget _legendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  LineChartData mainChart(List<MoodEntry> filteredEntries) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: 1,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= filteredEntries.length) {
                return const SizedBox();
              }
              final date = filteredEntries[value.toInt()].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              String text = '';
              switch (value.toInt()) {
                case 1:
                  text = 'Triste';
                  break;
                case 3:
                  text = 'Neutro';
                  break;
                case 5:
                  text = 'Feliz';
                  break;
              }
              return Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      minX: 0,
      maxX: filteredEntries.length.toDouble() - 1,
      minY: 0,
      maxY: 6,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: AppTheme.primaryColor.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final entry = filteredEntries[spot.x.toInt()];
              return LineTooltipItem(
                '${entry.mood}\n${DateFormat('dd/MM HH:mm').format(entry.date)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(filteredEntries.length, (index) {
            return FlSpot(
              index.toDouble(),
              filteredEntries[index].moodScore.toDouble(),
            );
          }),
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              Color dotColor;
              switch (filteredEntries[index].moodScore) {
                case 5:
                case 4:
                  dotColor = AppTheme.happyColor;
                  break;
                case 3:
                  dotColor = AppTheme.calmColor;
                  break;
                case 2:
                case 1:
                  dotColor = AppTheme.sadColor;
                  break;
                default:
                  dotColor = AppTheme.primaryColor;
              }
              return FlDotCirclePainter(
                radius: 5,
                color: dotColor,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
} 