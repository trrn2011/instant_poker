import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RingGameFieldWidget extends StatelessWidget {
  final TextEditingController sbController;
  final TextEditingController anteController;
  final TextEditingController minBuyinController;
  final TextEditingController maxBuyinController;
  final TextEditingController timebankController;

  RingGameFieldWidget({
    required this.sbController,
    required this.anteController,
    required this.minBuyinController,
    required this.maxBuyinController,
    required this.timebankController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFormField('SB', '100', '点', sbController),
        _buildFormField('アンティ', '0', '点', anteController),
        _buildFormField('MINバイイン', '100', 'BB', minBuyinController),
        _buildFormField('MAXバイイン', '200', 'BB', maxBuyinController),
        _buildFormField('タイムバンク', '30', '秒', timebankController),
      ],
    );
  }

  Widget _buildFormField(String label, String hint, String unit, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label),
          Expanded(child: Container()),
          Container(
            width: 100.0,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          SizedBox(width: 8.0),
          Text(unit),
        ],
      ),
    );
  }
}

