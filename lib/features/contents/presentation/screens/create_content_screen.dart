import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/short_line.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/content_track_search_screen.dart';

import 'package:music_is_life/core/widgets/box/hash_tag_input_box.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  ContentsController get _controller => Get.find<ContentsController>();

  // Image 저장 변수
  File? pickedImage;

  // Form Key
  final formKey = GlobalKey<FormState>();

  // 게시글 제목 컨트롤러
  final TextEditingController _titleController = TextEditingController();

  // 게시글 내용 컨트롤러
  final TextEditingController _contentController = TextEditingController();

  // 해시태그 내용 컨트롤러
  final TextEditingController _hashtagController1 = TextEditingController();
  final TextEditingController _hashtagController2 = TextEditingController();
  final TextEditingController _hashtagController3 = TextEditingController();

  // User 정보 불러오기
  MusicController get _music => Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    // 이전에 작성하다 만 게시물의 곡이 남아 있지 않도록 비운다.
    _music.clearPickedTrack();
  }

  // 컨텐츠 이미지
  _pickContentsImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 300,
    );
    setState(() {
      if (pickedImageFile != null) {
        pickedImage = File(pickedImageFile.path);
      }
    });
  }

  // 이미지 미리보기
  Widget _buildImagePreview() {
    if (pickedImage != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.file(
          pickedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              color: Colors.blue,
              size: 50,
            ),
            SizedBox(height: 15),
            Text(
              'Select your file',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }

  // 게시글 작성 후 저장
  Future<void> _createContentsAndPost() async {
    if (pickedImage == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류'),
            content: const Text('이미지를 선택해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    // 예전에는 곡을 고르지 않으면 selectTrack[0]에서 앱이 멈췄다.
    final track = _music.pickedTrack.value;
    if (track == null) {
      showErrorSnackBar(context, '게시물에 붙일 곡을 선택해 주세요.');
      return;
    }

    final result = await _controller.post(
      NewContent(
        title: _titleController.text,
        body: _contentController.text,
        image: pickedImage!,
        hashTags: [
          _hashtagController1.text,
          _hashtagController2.text,
          _hashtagController3.text,
        ],
        track: ContentTrack(
          name: track.name,
          artistsName: track.artistsName,
          imageUrl: track.imageUrl,
        ),
      ),
    );
    if (!mounted) return;
    // 예전에는 업로드 중 에러가 나면 로딩 화면이 풀리지 않았다.
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
      return;
    }

    //작성 완료 후 입력 필드 초기화

    _titleController.clear();
    _contentController.clear();
    _hashtagController1.clear();
    _hashtagController2.clear();
    _hashtagController3.clear();
    _music.clearPickedTrack();
    setState(() {
      pickedImage = null;
    });
    // 마이페이지에서 열린 화면이므로 돌아간다. (예전에는 마이페이지를 새로 push해서 화면이 쌓였다)
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: _controller.isPosting.value,
          child: StreamBuilder<UserProfile?>(
            stream: _controller.watchAuthor(_controller.uid),
            builder: (context, snapshot) {
              return snapshot.data != null
                  ? SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                  ),

                                  // 프로필 사진
                                  Positioned(
                                    top: 30,
                                    left: 10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 70,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(70),
                                        child: Image.network(
                                          snapshot.data!.profileImageUrl,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 프로필 아이디
                                  Positioned(
                                    top: 100,
                                    left: 170,
                                    child: Text(
                                      '${snapshot.data!.userName}님',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 140,
                                    left: 170,
                                    child: Text(
                                      '어떤 음악을 추천 받고 싶나요?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // 뒤로가기 버튼
                                  Positioned(
                                    top: 15,
                                    right: 10,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const ShortLine(color: Colors.amber),
                              const SizedBox(height: 10),

                              // 게시물 작성
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '게시물 작성',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const ShortLine(color: Colors.amber),
                              const SizedBox(height: 30),

                              // 게시물 이미지
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // 게시물 이미지 출력
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        _pickContentsImage();
                                      } catch (e) {
                                        const CircularProgressIndicator();
                                      }
                                    },
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      color: Colors.white,
                                      child: _buildImagePreview(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 컨텐츠 내용 입력.
                              Column(
                                children: [
                                  // 게시물 제목 입력
                                  DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: Colors.white,

                                    // 입력 창
                                    child: TextField(
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        hintText: ' 게시물 제목을 입력해 주세요.',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // 게시물 내용 입력
                                  DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: Colors.white,

                                    // 입력 창
                                    child: TextField(
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      controller: _contentController,
                                      decoration: const InputDecoration(
                                        hintText: ' 내용을 입력해 주세요.',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 해시태그
                                        HashTagInputBox(
                                          text: ' 해시태그',
                                          controller: _hashtagController1,
                                        ),

                                        HashTagInputBox(
                                          text: ' 해시태그',
                                          controller: _hashtagController2,
                                        ),

                                        HashTagInputBox(
                                          text: ' 해시태그',
                                          controller: _hashtagController3,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Height(80),
                                  const ShortLine(color: Colors.amber),
                                  const Height(10),

                                  // 게시물 작성
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '게시물 음악 검색',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Height(10),
                                  const ShortLine(color: Colors.amber),
                                  const Height(40),
                                  Obx(
                                    () => _music.pickedTrack.value == null
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ContentTrackSearchScreen()));
                                            },
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(10),
                                              dashPattern: const [10, 4],
                                              strokeCap: StrokeCap.round,
                                              color: Colors.white,
                                              child: const SpotifySearch(),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(30),
                                                ),
                                                child: Image.network(
                                                  _music.pickedTrack.value!
                                                      .imageUrl,
                                                  scale: 3.5,
                                                ),
                                              ),
                                              height10,
                                              Text(
                                                _music.pickedTrack.value!.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _music.pickedTrack.value!
                                                    .artistsName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),

                                  const Height(40),

                                  CheckButton(
                                    width: 60,
                                    height: 60,
                                    borderColor: Colors.redAccent,
                                    icon: Icons.check,
                                    iconColor: Colors.white,
                                    iconSize: 40,
                                    onTap: _createContentsAndPost,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class SpotifySearch extends StatelessWidget {
  const SpotifySearch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo/spotify_logo.png',
            scale: 2,
          ),
          height10,
          const Text(
            'Spotify에서 검색하기',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
