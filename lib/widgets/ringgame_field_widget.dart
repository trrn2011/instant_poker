import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_setting_provider.dart';

class RingGameFieldWidget extends StatelessWidget {
  const RingGameFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameSettingProvider>(
      builder: (context, gameSettings, child) {
        return Column(
          children: [
            _buildFormField(
              label: 'SB',
              hint: '100',
              unit: '点',
              onChanged: gameSettings.updateSb,
            ),
            _buildFormField(
              label: 'アンティ',
              hint: '0',
              unit: '点',
              onChanged: gameSettings.updateAnte,
            ),
            _buildFormField(
              label: 'MINバイイン',
              hint: '100',
              unit: 'BB',
              onChanged: gameSettings.updateMinBuyin,
            ),
            _buildFormField(
              label: 'MAXバイイン',
              hint: '200',
              unit: 'BB',
              onChanged: gameSettings.updateMaxBuyin,
            ),
            _buildFormField(
              label: 'タイムバンク',
              hint: '30',
              unit: '秒',
              onChanged: gameSettings.updateTimebank,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required String unit,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label),
          Expanded(child: Container()),
          Container(
            width: 100.0,
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 8.0),
          Text(unit),
        ],
      ),
    );
  }
}
