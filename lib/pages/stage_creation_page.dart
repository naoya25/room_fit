import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/core/constants/grid_size.dart';
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

    // --- 作成ボタン押下時の処理 ---
    Future<void> onCreatePressed() async {
      if (!validateInputs()) return;

      final w = int.parse(widthController.text);
      final h = int.parse(heightController.text);

      // 実際に使用する範囲だけ切り抜く
      final selectedGrid =
          roomGrid.value.sublist(0, h).map((row) => row.sublist(0, w)).toList();

      // Provider側のcreateStageを呼び出し
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

    // 入力が更新されるたびにバリデーションを実行
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
        appBar: AppBar(title: const Text('ステージ作成'), centerTitle: true),
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
              _GridSizeInput(
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

                    return _RoomGridInput(
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

/// 幅・高さ入力用Widget
class _GridSizeInput extends StatelessWidget {
  const _GridSizeInput({
    required this.widthController,
    required this.heightController,
    required this.widthError,
    required this.heightError,
  });

  final TextEditingController widthController;
  final TextEditingController heightController;
  final String? widthError;
  final String? heightError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 横幅
        Expanded(
          child: TextField(
            controller: widthController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '横幅',
              border: const OutlineInputBorder(),
              errorText: widthError,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 高さ
        Expanded(
          child: TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '高さ',
              border: const OutlineInputBorder(),
              errorText: heightError,
            ),
          ),
        ),
      ],
    );
  }
}

/// 部屋のグリッド編集UI
class _RoomGridInput extends HookWidget {
  const _RoomGridInput({
    required this.width,
    required this.height,
    required this.calculatedHeight,
    required this.roomGrid,
  });

  final int width;
  final int height;
  final double calculatedHeight;
  final ValueNotifier<List<List<bool>>> roomGrid;

  @override
  Widget build(BuildContext context) {
    final isDragging = useState(false);
    final mode = useState(GridMode.add);

    // ローカルで編集用のGrid（画面表示用）を管理
    final localGrid = useState(
      roomGrid.value.map((row) => List<bool>.from(row)).toList(),
    );

    // roomGrid本体が変わったら表示用を同期
    useEffect(() {
      localGrid.value =
          roomGrid.value.map((row) => List<bool>.from(row)).toList();
      return null;
    }, [roomGrid.value]);

    // 指定座標をタップ／ドラッグされた際に状態を更新
    void updateGrid(int x, int y) {
      if (x < 0 || x >= width || y < 0 || y >= height) return;

      final newValue = (mode.value == GridMode.add);
      if (localGrid.value[y][x] != newValue) {
        localGrid.value[y][x] = newValue;
        roomGrid.value[y][x] = newValue; // 本体も更新
      }
    }

    return Column(
      children: [
        // --- 追加／削除の切り替えボタン ---
        _ModeToggleButton(currentMode: mode),
        const SizedBox(height: 16),
        Text('部屋の配置をタップまたはドラッグして設定してください'),
        Text('横幅: $width  高さ: $height'),
        const SizedBox(height: 16),

        // --- グリッド本体 ---
        Container(
          width: double.infinity,
          height: calculatedHeight,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: GestureDetector(
            onPanStart: (details) {
              isDragging.value = true;
              final cellSize = calculatedHeight / height;
              final x = (details.localPosition.dx / cellSize).floor();
              final y = (details.localPosition.dy / cellSize).floor();
              updateGrid(x, y);
            },
            onPanUpdate: (details) {
              if (!isDragging.value) return;
              final cellSize = calculatedHeight / height;
              final x = (details.localPosition.dx / cellSize).floor();
              final y = (details.localPosition.dy / cellSize).floor();
              updateGrid(x, y);
            },
            onPanEnd: (_) {
              isDragging.value = false;
            },
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width,
              ),
              itemCount: width * height,
              itemBuilder: (context, index) {
                final x = index % width;
                final y = index ~/ width;
                final isActive = localGrid.value[y][x];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: isActive ? Colors.blue.shade200 : Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 追加／削除の切り替えボタン
class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({required this.currentMode});

  final ValueNotifier<GridMode> currentMode;

  Widget _buildButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final mode in GridMode.values)
          _buildButton(
            label: mode.label,
            isSelected: currentMode.value == mode,
            onTap: () => currentMode.value = mode,
          ),
      ],
    );
  }
}
