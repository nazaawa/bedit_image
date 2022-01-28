import 'dart:typed_data';

import 'package:bedit_image/common.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'crop_editor_helper.dart';
// import 'package:image_editor/image_editor.dart';

class EditeImage extends HookWidget {
  EditeImage(this.file, {this.isProfil = false, Key? key}) : super(key: key);

  final File file;

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final bool isProfil;

  @override
  Widget build(BuildContext context) {
    /// AspectRatios actuel
    final aspectRatio = useState<double?>(CropAspectRatios.original);

    //[Observation]: les variables doivent soit
    // avoir un nom bien explicite soit commenté.
    // !! Au mieux, commenté. Exemple.
    /// Montre les options AspectRatios ou non.
    final showCropOption = useState<bool>(false);

    final cropping = useState<bool>(false);

    final List<AspectRatioItem> aspectRatios = <AspectRatioItem>[
      AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
      AspectRatioItem(text: 'original', value: CropAspectRatios.original),
      AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
      AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
      AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
      AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
      AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
    ];

    useEffect(() {
      if (isProfil) {
        aspectRatio.value = CropAspectRatios.ratio1_1;
      }
    }, []);

    void flip() {
      editorKey.currentState!.flip();
    }

    void rotate(bool right) {
      editorKey.currentState!.rotate(right: right);
    }

    void reset() {
      editorKey.currentState!.reset();
    }

    Future<void> cropImage() async {
      if (cropping.value) {
        return;
      }
      String msg = '';
      try {
        cropping.value = true;

        //await showBusyingDialog();

        Uint8List? fileData;

        fileData = await cropImageDataWithNativeLibrary(
            state: editorKey.currentState!);
        final file = File.fromRawPath(fileData!);
        // return the file
        Navigator.of(context).pop(file);
      } catch (e, stack) {
        msg = 'save failed: $e\n $stack';
        debugPrint(msg);
      }
      cropping.value = false;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => cropImage(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ExtendedImage.file(
                file,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                extendedImageEditorKey: editorKey,
                initEditorConfigHandler: (state) {
                  return EditorConfig(
                    maxScale: 8.0,
                    cropRectPadding: const EdgeInsets.all(20.0),
                    hitTestSize: 20.0,
                    cropAspectRatio: aspectRatio.value,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      showCropOption.value = true;
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.crop),
                        Text(
                          "Crop",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => flip(),
                    child: Column(
                      children: const [
                        Icon(Icons.flip),
                        Text(
                          "Flip",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => rotate(false),
                    child: Column(
                      children: const [
                        Icon(Icons.rotate_left),
                        Text(
                          "Rotate left",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => rotate(true),
                    child: Column(
                      children: const [
                        Icon(Icons.rotate_right),
                        Text(
                          "Rotate right",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => reset(),
                    child: Column(
                      children: const [
                        Icon(Icons.restore),
                        Text("Reset"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showCropOption.value)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: aspectRatios.length,
                  itemBuilder: (_, int index) {
                    final AspectRatioItem item = aspectRatios[index];
                    return GestureDetector(
                      child: AspectRatioWidget(
                        aspectRatio: item.value,
                        aspectRatioS: item.text,
                        isSelected: item.value == aspectRatio.value,
                      ),
                      onTap: () {
                        aspectRatio.value = item.value;
                        showCropOption.value = false;
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
