import 'package:flutter/material.dart';
import '../utils/colors_util.dart';
import '../widgets/circle_container_widget.dart';
import 'package:provider/provider.dart';
import '../providers/game_setting_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSettings = Provider.of<GameSettingProvider>(context);

    return Scaffold(
      backgroundColor: ColorsUtil.backgroundPurple,
      appBar: AppBar(
        title: Text('ゲームをホスト'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/poker_table.png'),
                  fit: BoxFit.contain,
                ),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ゲーム設定',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'スモールブラインド: ${gameSettings.sb}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'アンティ: ${gameSettings.ante}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '最小バイイン: ${gameSettings.minBuyin}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '最大バイイン: ${gameSettings.maxBuyin}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'タイムバンク: ${gameSettings.timebank}秒',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
