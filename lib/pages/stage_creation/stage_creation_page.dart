import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/core/constants/grid_size.dart';
import 'package:room_fit/pages/stage_creation/components/grid_input.dart';
import 'package:room_fit/pages/stage_creation/components/grid_size_input.dart';
import 'package:room_fit/providers/stage_provider.dart';

enum GridMode {
  add,
  remove;

  get label {
    switch (this) {
      case GridMode.add:
        return '追加';
      case GridMode.remove:
        return '削除';
    }
  }
}

/// ステージ作成ページ
class StageCreationPage extends HookConsumerWidget {
  const StageCreationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- TextEditingController ---
    final stageNameController = useTextEditingController();
    final widthController = useTextEditingController(text: '20');
    final heightController = useTextEditingController(text: '18');

    // --- 部屋の2次元グリッド(最大サイズ)を管理 ---
    final roomGrid = useState<List<List<bool>>>(
      List.generate(maxGridRowNum, (_) => List.filled(maxGridColNum, false)),
    );

    // --- エラー表示用のState ---
    final stageNameError = useState<String?>(null);
    final widthError = useState<String?>(null);
    final heightError = useState<String?>(null);

    // --- 入力値チェック ---
    bool validateInputs() {
      // ステージ名
      if (stageNameController.text.isEmpty) {
        stageNameError.value = 'ステージ名を入力してください';
        return false;
      } else {
        stageNameError.value = null;
      }

      // 幅
      if (widthController.text.isEmpty) {
        widthError.value = '横幅を入力してください';
        return false;
      } else {
        final w = int.tryParse(widthController.text);
        if (w == null) {
          widthError.value = '数値を入力してください';
          return false;
        } else if (w < 1) {
          widthError.value = '1以上の値を入力してください';
          return false;
        } else if (w > maxGridColNum) {
          widthError.value = '$maxGridColNum以下の値を入力してください';
          return false;
        } else {
          widthError.value = null;
        }
      }

      // 高さ
      if (heightController.text.isEmpty) {
        heightError.value = '高さを入力してください';
        return false;
      } else {
        final h = int.tryParse(heightController.text);
        if (h == null) {
          heightError.value = '数値を入力してください';
          return false;
        } else if (h < 1) {
          heightError.value = '1以上の値を入力してください';
          return false;
        } else if (h > maxGridRowNum) {
          heightError.value = '$maxGridRowNum以下の値を入力してください';
          return false;
        } else {
          heightError.value = null;
        }
      }
      return true;
    }

    Future<void> onCreatePressed() async {
      if (!validateInputs()) return;

      final w = int.parse(widthController.text);
      final h = int.parse(heightController.text);

      final selectedGrid =
          roomGrid.value.sublist(0, h).map((row) => row.sublist(0, w)).toList();

      await ref
          .read(stageListProvider.notifier)
          .createStage(
            name: stageNameController.text,
            height: h,
            width: w,
            roomGrid: selectedGrid,
          );

      if (context.mounted) {
        context.go('/select');
      }
    }

    useEffect(() {
      stageNameController.addListener(validateInputs);
      widthController.addListener(validateInputs);
      heightController.addListener(validateInputs);
      return () {
        stageNameController.removeListener(validateInputs);
        widthController.removeListener(validateInputs);
        heightController.removeListener(validateInputs);
      };
    }, []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('お部屋の登録'), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ステージ名入力 ---
              TextField(
                controller: stageNameController,
                decoration: InputDecoration(
                  labelText: 'ステージ名',
                  border: const OutlineInputBorder(),
                  errorText: stageNameError.value,
                ),
              ),
              const SizedBox(height: 16),

              // --- 幅・高さ入力 ---
              GridSizeInput(
                widthController: widthController,
                heightController: heightController,
                widthError: widthError.value,
                heightError: heightError.value,
              ),
              const SizedBox(height: 24),

              // --- グリッド編集UI ---
              if (widthController.text.isNotEmpty &&
                  heightController.text.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = int.tryParse(widthController.text) ?? 0;
                    final h = int.tryParse(heightController.text) ?? 0;
                    if (w == 0 || h == 0) return const SizedBox.shrink();

                    final screenWidth = constraints.maxWidth;
                    final cellSize = screenWidth / w;
                    final calculatedHeight = cellSize * h;

                    return RoomGridInput(
                      width: w,
                      height: h,
                      calculatedHeight: calculatedHeight,
                      roomGrid: roomGrid,
                    );
                  },
                ),

              const SizedBox(height: 24),
              // --- 作成ボタン ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCreatePressed,
                  child: const Text('ステージを作成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
