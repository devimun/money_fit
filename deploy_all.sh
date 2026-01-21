#!/bin/bash

# 에러가 나면 즉시 스크립트 중단 (안전장치)
set -e

# --------------------------------------------------------
# 💎 RUBY 환경 설정 (충돌 방지 코드 추가됨)
# --------------------------------------------------------
# rbenv를 초기화해서 Homebrew Ruby와의 충돌을 막습니다.
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then 
  eval "$(rbenv init -)" 
fi

echo "============================================="
echo "Project MoneyFit 통합 배포 시스템"
echo "============================================="
echo "어떤 작업을 수행하시겠습니까?"
echo "1) 🧪 Beta 배포 (TestFlight + Internal Test)"
echo "2) 📝 메타데이터 업데이트 (텍스트만, 빠름)"
echo "3) 🖼️  이미지 업데이트 (스크린샷 변경시)"
echo "4) 🚀 정식 출시 (Release / 심사 제출)"
echo "============================================="
read -p "번호를 입력하세요 (1/2/3/4): " choice

# 선택에 따라 레인(Lane) 이름 설정
if [ "$choice" == "1" ]; then
  LANE_NAME="beta"
  ACTION_NAME="Beta 배포"
elif [ "$choice" == "2" ]; then
  LANE_NAME="update_metadata"
  ACTION_NAME="메타데이터 업데이트"
elif [ "$choice" == "3" ]; then
  LANE_NAME="update_images"
  ACTION_NAME="이미지 업데이트"
elif [ "$choice" == "4" ]; then
  LANE_NAME="release"
  ACTION_NAME="정식 출시(Release)"
else
  echo "❌ 잘못된 입력입니다. 스크립트를 종료합니다."
  exit 1
fi

echo ""
echo "🔥 [1/2] Android $ACTION_NAME 시작..."
cd android
bundle exec fastlane $LANE_NAME
cd ..

echo ""
echo "🔥 [2/2] iOS $ACTION_NAME 시작..."
cd ios
bundle exec fastlane $LANE_NAME
cd ..

echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다! 고생하셨습니다."