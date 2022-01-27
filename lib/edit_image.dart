import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_editor/image_editor.dart';

enum Status { none, running, stopped, paused }

class EditeImage extends HookWidget {
  EditeImage({Key? key}) : super(key: key);

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  @override
  Widget build(BuildContext context) {
    final status = useState(CropAspectRatios.original);
    //final _aspectRatio = CropAspectRatios();
    bool isProfil = false;
    final _show = useState(false);
    const imageTestUrl =
        "https://image.shutterstock.com/image-photo/riga-latvia-11052019-old-man-600w-1562586589.jpg";
    return Scaffold(
        appBar: AppBar(
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: () {})],
        ),
        body: isProfil == true
            ? Center(
                child: SizedBox(
                    height: 400,
                    width: 350,
                    child: ExtendedImage.network(
                      imageTestUrl,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.editor,
                      extendedImageEditorKey: editorKey,
                      initEditorConfigHandler: (state) {
                        return EditorConfig(
                            maxScale: 8.0,
                            cropRectPadding: const EdgeInsets.all(20.0),
                            hitTestSize: 20.0,
                            cropAspectRatio: CropAspectRatios.ratio1_1);
                      },
                    )),
              )
            : Center(
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                          height: 400,
                          width: 350,
                          child: ExtendedImage.network(
                            imageTestUrl,
                            fit: BoxFit.contain,
                            mode: ExtendedImageMode.editor,
                            extendedImageEditorKey: editorKey,
                            initEditorConfigHandler: (state) {
                              return EditorConfig(
                                  maxScale: 8.0,
                                  cropRectPadding: const EdgeInsets.all(20.0),
                                  hitTestSize: 20.0,
                                  cropAspectRatio: status.value);
                            },
                          )),
                    ),
                    _show.value == true
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                box("Custom", () {
                                  status.value = CropAspectRatios.original;
                                  _show.value = false;
                                }),
                                box("origine", () {
                                  status.value = CropAspectRatios.original;
                                                                    _show.value = false;

                                }),
                                box("1*1", () {
                                  status.value = CropAspectRatios.ratio1_1;
                                                                    _show.value = false;

                                }),
                                box("4.3", () {
                                  status.value = CropAspectRatios.ratio4_3;
                                                                    _show.value = false;

                                }),
                                box("3*4", () {
                                  status.value = CropAspectRatios.ratio3_4;
                                                                    _show.value = false;

                                }),
                                box("9-*16", () {
                                  status.value = CropAspectRatios.ratio9_16;
                                                                    _show.value = false;

                                })
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
        bottomNavigationBar: isProfil == true
            ? null
            : BottomNavigationBar(
                backgroundColor: Colors.blue,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.crop,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Crop',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.flip,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Flip',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.rotate_left,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Rotate left',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.rotate_right,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Rotate right',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                onTap: (int index) {
                  switch (index) {
                    case 0:
                      _show.value = true;
                      break;
                    case 1:
                      flip();
                      break;
                    case 2:
                      rotate(true);
                      break;
                    case 3:
                      rotate(false);
                      break;
                  }
                },
                currentIndex: 0,
                selectedItemColor: Colors.blue,
                //  unselectedItemColor: Theme.of(context).primaryColor,
              ));
  }

  void flip() {
    editorKey.currentState!.flip();
  }

  void rotate(bool right) {
    editorKey.currentState!.rotate(right: right);
  }

  show(_show) {
    _show.value = true;
  }
  Future<void> crop([bool test = false]) async {
    final ExtendedImageEditorState? state = editorKey.currentState;
    final Rect? rect = state!.getCropRect();
    final EditActionDetails? action = state.editAction;
    final double radian = action!.rotateAngle;

    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List img = state.rawImageData;

    final ImageEditorOption option = ImageEditorOption();

    option.addOption(ClipOption.fromRect(rect!));
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    if (action.hasRotateAngle) {
      option.addOption(RotateOption(radian.toInt()));
    }
/* 
    option.addOption(ColorOption.saturation(sat));
    option.addOption(ColorOption.brightness(bright + 1));
    option.addOption(ColorOption.contrast(con)); */

    option.outputFormat = const OutputFormat.jpeg(100);

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));

    final DateTime start = DateTime.now();
    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    print('result.length = ${result!.length}');

    final Duration diff = DateTime.now().difference(start);
    imageTestUrl.writeAsBytesSync(result);
    print('image_editor time : $diff');
/*     Future.delayed(Duration(seconds: 0)).then(
      (value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SaveImageScreen(
                  arguments: [image],
                )),
      ),
    ); */
  }
  Widget box(String label, [onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        color: Colors.blue,
        child: Center(child: Text(label, textAlign: TextAlign.center)),
      ),
    );
  }
}
