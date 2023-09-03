import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../../ui/tap/home_cardbox.dart';
import 'dart:io';

import '../../model/notification.dart';
import '../../services/local_storage.dart';
import '../../rest_api/item_api.dart';
import '../model/poll.dart';
import '../model/session.dart';
import '../model/user.dart';
import '../rest_api/api.dart';
import '../rest_api/card_api.dart';
// import '../rest_api/cookie_api.dart';
import '../rest_api/poll_api.dart';
import '../rest_api/user_api.dart';
import '../services/secure_storage.dart';
import '../resource/kConstant.dart';
import '../model/omg_pass.dart';
import '../model/omg_card_model.dart';
import '../services/image_handler.dart';

final StateService service = Get.put(StateService());

class StateService extends GetxService {
  // sign up 등록 에서만 시용
  RxString phoneNumber = ''.obs;
  RxString username = ''.obs;
  RxString userEmail = 'jangwon.jung@gmail.com'.obs;
  RxString profileImage = ''.obs;
  RxString department = ''.obs;   // 소속 또는 학교
  RxString duty = ''.obs;
  RxString pKey = ''.obs;

  RxInt userSchoolGrade = 0.obs;    // 0 -> 중학교, 1 -> 고등학교
  RxInt userGender = 0.obs;       // 0 -> 남, 1 -> 여
  RxString userSchoolName = ''.obs;   // 학교 이름
  RxInt userSchoolId = 0.obs;   // 학교 id for internal server
  RxInt userSchoolYear = 1.obs;   // 1,2,3학년
  RxInt userSchoolClass = 1.obs;   // 1 ~ 20 반
  RxString phoneNumberToken = ''.obs;   // phone number token
  Rx<Paging> schoolPageCursor = Paging().obs;   // search school scroll up
  // user info
  Rx<User> userMe = User().obs;   // user 정보
  // rest api
  RxString accessToken = ''.obs;  // token
  // vote
  Rx<int> totalCookie = 100.obs;  // number of cookies
  Rx<VoteStatus> voteStatus = VoteStatus.none.obs;   // 투표 진행 상태 저장
  Rx<CardBatch> cardBatch = CardBatch().obs;    // 투표 한 세트 (12개) 혹은 잔여 투표
  Rx<SendSmsResult> sendSMSResult = SendSmsResult.none.obs;   // sms 보낸 결과 (상태) 저장
  RxList<String> buddyInvited = <String>[].obs;    // 초대장 보내 전화번호 목록 -> 이후 contact 리스트에서 안보이게
  RxBool hasVoteCountdownTriggered = false.obs;    // false -> 투표 가능, true -> 다음 투표까지 카운트다운 시작 (30분)
  // RxBool hasVoteOpen = false.obs;   // true -> 카드 투표 시작, false -> 시작한 투표 없음
  // RxBool hasVoteOpenCompleted = true.obs;   // 시간한 투표가 정상 종료 되는지 상태. false -> 남은 투표 있음
  RxInt spectorModeCount = 3.obs;   // 상태 저장, 하루 3회 가능, 매일 reset
  RxInt voteDirectCount = 5.obs;    // 상태 저장, 하루 5회, 매일 reset
  // poll
  Rx<PollOpen> pollOpen = PollOpen().obs;   // (app init) 학교 인기 투표 데이터
  // cookie inbox
  RxBool isFeedHiding = false.obs;  // true -> hide feeding
  Rx<Filter4receive> cardBoxFilter4Receive = Filter4receive.all.obs;   // 받은 카드 필터 옵션
  Rx<Filter4send> cardBoxFilter4Send = Filter4send.all.obs;   // 보낸 카드 필터 옵션
  RxInt cookieBalance = 0.obs;    // 쿠키 획득 후 새로운 쿠키 총 수량, 앱에 표시 수량
  // notification
  RxInt cardBadge = 0.obs;    // 카드 배지
  RxInt contactBadge = 0.obs;    // 연락처 배지
  RxBool homeRedDot = false.obs;  // 홈 red dot 표시
  // settings - main
  RxBool showBestCard = true.obs;   // 최고의 카드 표시
  // settings - vote
  RxBool voteSettingsHasNoFavorite = false.obs;  // 선호도 없음
  RxBool voteSettingsIsSameSchool = false.obs;  // 같은 학교
  RxBool voteSettingsIsSameGrade = false.obs;  // 같은 학년
  RxBool voteSettingsIsBoy = false.obs;  // 남학생
  RxBool voteSettingsIsGirl = false.obs;  // 여학생
  // settings - alarm
  RxBool alarm4CardArrival = true.obs;   // 카드 도팍 알림
  RxBool alarm4CardReply  = true.obs;   // 카드 답글 알림
  RxBool alarm4CardResetDone = true.obs;  // 카드 리셋 알림
  RxBool alarm4Event = true.obs;    // 이벤트 알림
  // settings - delete account
  RxBool deleteAccountOption1 = false.obs;   // 사용안함
  RxBool deleteAccountOption2 = false.obs;   // 비싸요
  RxBool deleteAccountOption3 = false.obs;   // 새계정
  RxBool deleteAccountOption4 = false.obs;   // 친구 없음
  RxBool deleteAccountOption5 = false.obs;   // 사용이 어려워요
  // item & payment
  Rx<OmgPassInfo> omgPassInfo = OmgPassInfo().obs;    // omg pass info
  Rx<OmgPassStatus> omgPassStatus = OmgPassStatus.none.obs;  // omg pass 상태 저장
  // timer for sms auth number
  Rx<Duration> countdown3min = const Duration(minutes: 3).obs;   // countdown 3 min
  Timer? _timer4OTP;
  // timer for vote
  Rx<Duration> countdown30min = const Duration(minutes: 60).obs;   // countdown 3 min
  Timer? _timer4Vote;
  // timer for account recovery
  Rx<Duration> countdown120hour = const Duration(hours: 120).obs;   // countdown 120 hour
  Timer? _timer4AccountRecovery;
  // state control
  RxDouble bottomMargin = (0.0).obs;  // ios -> 0, android -> 20
  RxBool hasModalSheetDraggable = false.obs;   // true -> bottom modal sheet enable drag

  RxBool isVoteComplete = false.obs;

  void setBottomMarginByPlatform() {
    if (Platform.isAndroid) {
      bottomMargin.value = 20.0;
    }
  }

  /// set user config for internal use @ start up the app   todo > 탈퇴 신청 확인 > 타이머 세팅
  Future<UserType> initializeApp() async {
    UserType type;
    bool isUserRegistered = await getAccessToken();
    print('---> check sign in state: isUserRegistered > $isUserRegistered');

    if (isUserRegistered) {   // 기존 유저 -> user type registered
      type = await getUserInfo();
    } else {  // 신규 유저 -> user type newbie
      type = UserType.newbie;
    }
    return Future.value(type);
  }

  Future<UserType> getUserInfo() async {
    UserType out;
    HttpsResponse res = await UserApi.getUserMe();
    print('---> service > getUserInfo > userMe: ${res.body}');
    if (res.statusType == StatusType.success) {   // 기존 회원
      userMe.value = User.fromJson(res.body);
      userMe.value.printOut();
      userMe.value.school?.openForVote = true;   // todo > test only
      userMe.value.followingCount = 4;    // todo > test only
      _downloadProfileImage();
      omgPassStatus.value = await getOmgPassStatus();
      /// get user type
      out = userMe.value.userType;
    } else {    // 긴규 회원
      out = UserType.newbie;
    }
    await _getInitDateFromServer();
    return Future.value(out);
  }

  Future<void> _getInitDateFromServer() async {
    _checkCountdownTimer();
    await _getCookieBalance();
    await _getPollOpen();
    await _getVoteCardBatch();
  }

  void _checkCountdownTimer() async {
    String? res = await LocalStorageService.getString(kStorageKey.voteCountdownTime);
    if (res != null) {
      DateTime countdownStartTime = DateTime.parse(res);
      DateTime now = DateTime.now();
      Duration diff = now.difference(countdownStartTime);
      if (diff >= const Duration(minutes: 30)) {    // waiting time 30min over
        service.hasVoteCountdownTriggered.value = false;
      } else {  // still in 30 min waiting ime
        service.hasVoteCountdownTriggered.value = true;
        startCountdownTimer4Vote(const Duration(minutes: 5) - diff); // 30분에서 남은 시간 부터 시작 // todo > 30 min
      }
    } else {  // null -> 앱 초기 상태
      service.hasVoteCountdownTriggered.value = false;
    }
    print('---> app init > _checkCountdownTimer | time: $res');
  }

  Future<void> _getCookieBalance() async {    // 초기 쿠기 balance 가져오기
    final res = await getCookieBalance();
    if (res != null) cookieBalance.value = res;
  }

  Future<void> _getPollOpen() async {
    final HttpsResponse res = await PollApi.getPollOpen();
    if (res.statusType == StatusType.success) {
      pollOpen.value = PollOpen.fromJson(res.body);
    }
  }

  Future<dynamic> _getVoteCardBatch() async {
    dynamic out;
    HttpsResponse res = await CardApi.postCardBatchStart();   // load new cards set
    if (res.statusType == StatusType.success) {
      cardBatch.value = CardBatch.fromJson(res.body);
      if (cardBatch.value.cards?.isNotEmpty ?? false) {
        voteStatus.value = VoteStatus.ready;
        out = res.body;
      }
    } else {
      HttpsResponse res = await CardApi.getCardBatchOpen();   // load unfinished card set
      if (res.statusType == StatusType.success) {
        cardBatch.value = CardBatch.fromJson(res.body);
        if (cardBatch.value.cards?.isNotEmpty ?? false) {
          voteStatus.value = VoteStatus.inProcess;
          out = res.body;
        }
      }
    }
    print('---> _getVoteCardBatch > vote status: ${voteStatus.value}');
  }

  Future<dynamic> updateCookieBalance() async {
    final res = await getCookieBalance();
    if (res != null) {
      cookieBalance.value = res;
    }
    print('---> service update cookie balance: ${cookieBalance.value}');
    return res;
  }

  Future<dynamic> getCookieBalance() async {
    int? out;
    final HttpsResponse res = await IdenApi.getIdenTokenBalance();
    if (res.statusType == StatusType.success) {
      out = res.body;
    }
    return out;
  }

  Future<bool> updateUserMeInfo(dynamic data, bool hasProfile) async {
    bool out = false;
    if (data != null) {
      // userMe.value.update(data);
      userMe.value = User.fromJson(data);
      if (hasProfile) {
        // final res = await _downloadProfileImage();
        out = true;
      } else {
        out = true;
      }
    }
    return Future.value(out);
  }

  Future<bool> _downloadProfileImage() async {
    bool out = false;
    if (userMe.value.profileImageKey?.isNotEmpty ?? false) {
      final String url = userMe.value.profileImageKey!;
      profileImage.value = await ImageHandler.downloadAndSaveImage(url);
      out = true;
    }
    print('---> download: out: $out');
    return out;
  }

  Future<OmgPassStatus> getOmgPassStatus() async {
    OmgPassStatus status = OmgPassStatus.none;
    HttpsResponse res = await ItemApi.getMyOmpPass();
    if (res.statusType == StatusType.success) {
      omgPassInfo.value = OmgPassInfo.fromJson(res.body);

      if (omgPassInfo.value.status != null) {
        status = omgPassInfo.value.status!;
        // status = OmgPassStatus.activeSub;  // todo ? test only
      }
    }
    return Future.value(status);
  }

  Future<bool> updateUserProfile(String field, String value) async {
    bool out;
    final HttpsResponse res = await UserApi.updateUserMe(field, value);
    if (res.statusType == StatusType.success) {
      final result = await updateUserMeInfo(res.body, false);
      if (result) {
        out = true;
      } else {
        out = false;
      }
    } else {
      out = false;
    }
    return Future.value(out);
  }

  // auth with phone number
  Future<UserState> verifyWithSmsCode(String code) async {
    UserState state = UserState();
    final HttpsResponse response = await UserApi.postVerifySmsCode(code);
    if (response.statusType == StatusType.success) {
      final res = response.body;
      state = UserState.fromJson(res);
      phoneNumberToken.value = state.phoneNumberToken ?? '';
      state.isVerified = true;
    } else {
      state.isVerified = false;
    }
    return Future.value(state);
  }

  // save user info to local storage
  void saveUser2Local() {
    OmgSecureStorage.instance.saveKey(kStorageKey.username, username.value);
    OmgSecureStorage.instance.saveKey(kStorageKey.phoneNumber, phoneNumber.value);
    OmgSecureStorage.instance.saveKey(kStorageKey.school, userSchoolName.value);
    OmgSecureStorage.instance.saveKey(kStorageKey.grade, userSchoolGrade.value.toString());
    OmgSecureStorage.instance.saveKey(kStorageKey.gender, userGender.value.toString());
    // OmgSecureStorage.instance.saveKey(kStorageKey.profileImage, profileImage.value);
  }

  // 중학교/고등학교 구분
  int checkSchoolGrade(String school) {
    int out;
    if (school.contains('중학교')) {
      userSchoolGrade.value = 0;
      out = 0;
    } else {  // 고등학교
      userSchoolGrade.value = 1;
      out = 1;
    }
    return out;
  }

  // timer for sms OTP number
  void startTimer4OTP() {
    _timer4OTP = Timer.periodic(const Duration(seconds: 1), (_) =>
        _setCountdown4OTP());
  }
  void cancelTimer4OTP() {
    _timer4OTP?.cancel();
  }
  void reStartTimer4OTP() {
    cancelTimer4OTP();
    countdown3min.value = const Duration(minutes: 3);
    startTimer4OTP();
  }
  void _setCountdown4OTP() {
    final seconds = countdown3min.value.inSeconds - 1;
    if (seconds < 0) {
      _timer4OTP?.cancel();
      countdown3min.value = const Duration(minutes: 1);
    } else {
      countdown3min.value = Duration(seconds: seconds);
    }
  }

  // timer to wait for next vote (30 min)
  void startCountdownTimer4Vote(Duration? duration) {
    // _timer4Vote?.cancel();    // 타이머 리셋
    hasVoteCountdownTriggered.value = true;
    // saveVoteCountdownTime(DateTime.now().toIso8601String());  // 로컬에 타이머 시작 시간 저장 -> 앱 다시 시작할 때 확인
    if (duration != null) {
      countdown30min.value = duration;
    } else {
      countdown30min.value = const Duration(minutes: 60);
    }
    _timer4Vote = Timer.periodic(const Duration(seconds: 1),
            (_) => _setCountdown4Vote());
  }
  void cancelTimer4Vote() {
    _timer4Vote?.cancel();
    // countdown30min.value = const Duration(minutes: 5);
    hasVoteCountdownTriggered.value = false;
  }
  // void reStartTimer4Vote() {
  //   cancelTimer4Vote();
  //   countdown30min.value = const Duration(minutes: 5);
  //   startTimer4Vote();
  // }
  void _setCountdown4Vote() {
    final seconds = countdown30min.value.inSeconds - 1;
    if (seconds < -1) {   // 타이머에 00:00 까지 표시하고 이후 리셋
      _timer4Vote?.cancel();
    } else {
      countdown30min.value = Duration(seconds: seconds);
    }
  }
  void voteCountdownDone() {
    hasVoteCountdownTriggered.value = false;  // false -> 타이머 종료 (투표 가능)
    voteStatus.value = VoteStatus.ready;
  }

  // timer for account recovery (max 120 hour)
  void setTimer4AccountRecovery(String time) {
    DateTime deletedAt = DateTime.parse(time);
    Duration diff = DateTime.now().difference(deletedAt);
    countdown120hour.value = const Duration(hours: 120) - diff;   // 120시간 - 삭제 요청한 시간 -> 타이머 시작 시간
    _startTimer4AccountRecovery();
  }
  void _startTimer4AccountRecovery() {
    _timer4AccountRecovery = Timer.periodic(const Duration(seconds: 1), (_) =>
        _setCountdown4AccountRecovery());
  }
  void cancelTimer4AccountRecovery() {
    _timer4AccountRecovery?.cancel();
  }
  void reStartTimer4AccountRecovery() {
    cancelTimer4AccountRecovery();
    countdown120hour.value = const Duration(minutes: 1);
    _startTimer4AccountRecovery();
  }
  void _setCountdown4AccountRecovery() {
    final seconds = countdown120hour.value.inSeconds - 1;
    if (seconds < 0) {
      _timer4AccountRecovery?.cancel();
      countdown120hour.value = const Duration(hours: 120);
    } else {
      countdown120hour.value = Duration(seconds: seconds);
    }
  }

  String calcAge14() {
    DateTime today = DateTime.now();
    int year = today.year - 14;
    return '$year년 ${today.month}월 ${today.day}일';
  }

  /// access token to save and read from secure storage
  void saveAccessToken(String token) {
    accessToken.value = token;
    OmgSecureStorage.instance.saveKey(kStorageKey.accessToken, token);
  }

  Future<bool> getAccessToken() async {
    bool out;
    final token = await OmgSecureStorage.instance.getKey(kStorageKey.accessToken);
    if (token != null) {
      accessToken.value = token;
      out = true;
    } else {
      out = false;
    }
    print('---> get access token > token: $token');
    return Future.value(out);
  }

  /// general local storage using sharedPreference
  void saveWriteInVoteCount() {
    LocalStorageService.saveInt(kStorageKey.writeInVoteCount, voteDirectCount.value);
  }
  void saveSpectorModeCount() {
    LocalStorageService.saveInt(kStorageKey.spectorModeCount, spectorModeCount.value);
  }
  void saveVoteCountdownTime() {
    String time = DateTime.now().toIso8601String();
    LocalStorageService.saveString(kStorageKey.voteCountdownTime, time);
  }

  /// generate sample candidates
  List<Candidate> generateSampleCandidates() {
    List<Candidate> candidates = [];
    final random = Random();

    List<int> numbers = List<int>.generate(10, (index) => index); // Create a list from 0 to 11
    for (var i = numbers.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = numbers[i];
      numbers[i] = numbers[j];
      numbers[j] = temp;
    }
    List<int> shuffledNumbers = numbers;
    print('---> shuffledNumbers: $shuffledNumbers');
    for (int i=0; i<4; i++) {
      candidates.add(Candidate(
        user: User(
          name: kSamples.names[shuffledNumbers[i]],
          affiliation: kSamples.affiliations[shuffledNumbers[i]],
          profileImageKey: kSamples.profiles[shuffledNumbers[i]],
          gender: kSamples.genders[shuffledNumbers[i]],
        )
      ));
    }
    return candidates;
  }

  /// generate sample users
  List<OmgCard> generateSampleCards() {
    List<OmgCard> cards = [];
    for (int i=0; i<5; i++) {
      cards.add(OmgCard(
        question: kSamples.questions[i],
        emoji: kSamples.emojis[i].url,
        candidates: generateSampleCandidates()
      ));
    }
    return cards;
  }
}

enum SendSmsResult {
  succeed,
  cancel,
  none
}

enum PageCursor {
  before,
  after;
}

class Paging {
  Paging({
    this.beforeCursor,
    this.afterCursor,
    this.pageCursor
  });

  String? beforeCursor;
  String? afterCursor;
  PageCursor? pageCursor;

  factory Paging.fromJson(Map<String, dynamic> data) {
    return Paging(
      beforeCursor: '${data['beforeCursor']}',
      afterCursor: data['afterCursor'],
    );
  }

  void printOut() {
    print('---------  paging  ----------');
    print('---> beforeCursor: $beforeCursor');
    print('---> afterCursor: $afterCursor');
    print('-----------  end   -----------');
  }

  void reset() {
    beforeCursor = null;
    afterCursor = null;
  }
}