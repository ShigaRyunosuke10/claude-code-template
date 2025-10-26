#!/bin/bash
# AI完全自律実行システム フェーズ切り替えスクリプト

set -e

PHASE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHASES_DIR="$SCRIPT_DIR/../phases"
CURRENT_PHASE_FILE="$SCRIPT_DIR/../.current-phase"

if [ -z "$PHASE" ]; then
  echo "使用方法: $0 <1|2|3>"
  echo ""
  echo "フェーズ:"
  echo "  1: Observer Mode (停止ルール検知のみ)"
  echo "  2: Conservative Healing (既知処方のみ)"
  echo "  3: Full Autonomous (全機能有効化)"
  exit 1
fi

case "$PHASE" in
  1)
    PHASE_NAME="Observer Mode"
    PHASE_FILE="$PHASES_DIR/phase1-observer.json"
    ;;
  2)
    PHASE_NAME="Conservative Healing"
    PHASE_FILE="$PHASES_DIR/phase2-conservative.json"
    ;;
  3)
    PHASE_NAME="Full Autonomous"
    PHASE_FILE="$PHASES_DIR/phase3-full-autonomous.json"
    ;;
  *)
    echo "❌ 無効なフェーズ: $PHASE"
    echo "有効な値: 1, 2, 3"
    exit 1
    ;;
esac

if [ ! -f "$PHASE_FILE" ]; then
  echo "❌ フェーズ設定ファイルが見つかりません: $PHASE_FILE"
  exit 1
fi

echo "🔄 フェーズ切り替え: Phase $PHASE ($PHASE_NAME)"
echo ""

# 現在のフェーズを保存
echo "$PHASE" > "$CURRENT_PHASE_FILE"

# フェーズ設定を表示
echo "📋 Phase $PHASE 設定:"
cat "$PHASE_FILE" | grep -E '"phaseName"|"duration"|"mode"|"enabled"' | head -10

echo ""
echo "✅ Phase $PHASE に切り替えました"
echo ""
echo "次のステップ:"
echo "  1. playwright-test-healer.md を Phase $PHASE 設定に更新"
echo "  2. /e2e-full でテスト実行"
echo "  3. Telemetry 確認: .serena/memories/testing/phase${PHASE}_telemetry.json"
echo ""
echo "詳細: .claude/phases/ROLLOUT_GUIDE.md を参照"
