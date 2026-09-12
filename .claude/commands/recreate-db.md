# Render DB 再作成（現在は実行禁止 / 参照用）

## ステータス

**Canonical: Not Approved ／ SK ID: 未付与 ／ 実行禁止（参照用）**

スクリプト本体の安全化と自動運用監視は実装完了。
ただし **Render 側の前提が未設定**であり、**end-to-end 実機テストが未実施**のため実行しない。

| 項目 | 状態 |
| --- | --- |
| **R2** 非対話実行の fail-open 封鎖 | **PASS** |
| **R1** 削除対象を Enme DB 1件のみに限定（**実環境整合済み** 2026-09-12） | **PASS** |
| **Case B destructive-operation guard** | **PASS** |
| 既存DB 0件時の create-only 分岐 | **PASS** |
| dry-run | **PASS** |
| **R4** buildCommand を一切変更しない | **PASS** |
| **R5** cleanup / 中断時状態報告 / 推測復元なし | **PASS** |
| **R6** secret をディスクへ書かない | **PASS** |
| **R7** env-vars PUT を不変条件で検証 | **PASS** |
| 実行ログ（run ID / mode / 各段階 / 結果 / exit code） | **PASS** |
| 成功・失敗通知（無言失敗防止） | **PASS** |
| **R10** 個人情報の hardcode 解消 | **PASS** |
| deploy 判別（success / failed / canceled / timeout） | **PASS** |
| deploy 監視上限（**実測整合済み** 2026-09-12 / 600秒 → 3000秒） | **PASS** |
| health check（health endpoint ＋ DB依存ページ ＋ DB行描画） | **PASS** |
| automatic mode | **PASS** |
| launchd 再有効化 | **未実施（Safety Hold 中）** |
| end-to-end 自動再作成テスト（実機） | **未実施** |

## 実行前に必要な Render 側の前提（いずれも現時点で未設定）

1. **Case B policy marker**（非secret）を Web Service の環境変数に設定する。
   `ENME_DB_RESET_POLICY` = `DEMO_RESET_ALLOWED`（**完全一致**。未設定・空・typo・別値はすべて停止）
   → **現時点では未設定のため、実行しても exit 31 で停止する。**
2. **buildCommand が `bin/render-build.sh` を参照していること。**
   本スクリプトは buildCommand を変更しないため、参照していなければ exit 23 で停止する。
   seed は `bin/render-build.sh` 側の条件分岐（空DBなら `db:seed`）に委ねる。

## Claude Code はこのスクリプトを実行しない

**Claude はこのコマンドからスクリプトを実行してはならない。**
`/recreate-db` は手順を参照するためのものであり、実行トリガーではない。

- Claude が `scripts/recreate_db.sh` を実行しない（`--dry-run` / `--automatic` 付きでも実行しない）
- Claude が `--yes` / `--automatic` を独断で付与しない
- Claude Code の Bash 実行環境は**非対話（非TTY）**であり、
  明示フラグなしの非対話実行は **exit 3 で拒否される**

ユーザーから明示的な実行指示があった場合も、**Claude が代行せず**、手動実行手順を案内する。

## 手動実行（前提充足かつ E2E テスト後のみ）

まず dry-run で計画を確認する（破壊的操作なし・通知なし）:

    cd '/Users/tsujinanako/Desktop/ポートフォリオ用/Enme'
    bash scripts/recreate_db.sh --dry-run

実行する場合:

    cd '/Users/tsujinanako/Desktop/ポートフォリオ用/Enme'
    bash scripts/recreate_db.sh

確認文字列 `DELETE ENME DB` を正確に入力しない限り中止される。

## モードと引数仕様

| mode | 起動方法 | 非対話 | 確認文字列 | ログ | 通知 |
| --- | --- | --- | --- | --- | --- |
| manual | 引数なし / `--yes` | `--yes` 時のみ可 | 引数なし時は必須 | 出力（失敗しても続行） | なし |
| dry-run | `--dry-run`（`--yes` と併用可） | `--yes` 併用時のみ可 | 不要 | 出力 | **なし** |
| automatic | `--automatic` | **可** | 不要 | **必須**（不可なら exit 60） | **必須** |

許可される組み合わせは **引数なし / `--yes` / `--dry-run` / `--yes --dry-run` / `--automatic`** のみ。

- `--automatic` と `--dry-run` は**排他**（exit 2）
- `--automatic` と `--yes` の併用は不可（`--automatic` が非対話許可を含むため / exit 2）
- 同一フラグの重複・3個以上・不明な引数は **exit 2**
- 明示フラグなしの非対話実行は **exit 3**

## 処理フロー

    1. サービス情報取得（ownerId / buildCommand 確認）  … 不明なら STOP
    2. Case B policy marker 確認                       … 完全一致しなければ STOP
    3. 既存 Enme DB の特定                              … 2件以上 / 解析不能なら STOP
    4. 実行計画の表示                                    … --dry-run はここで終了
    5. 既存 DB の削除                                    … 0件ならスキップ（create-only）
    6. 新しい DB の作成
    7. DB 準備待機 + 接続情報取得                         … 接続文字列はログに出さない
    8. DATABASE_URL 更新（R7 検証済み）+ deploy           … buildCommand は変更しない
    9. health check                                    … deploy 成功だけでは SUCCESS にしない

## R1 — Enme DB 識別条件（2026-09-12 Preflight で実環境検証済み）

一覧レスポンス（`GET /postgres?ownerId=...&limit=20`）で**実際に取得できるフィールドのみ**を使用する。

| 条件 | 判定 |
| --- | --- |
| `name` | `enme-db-` で**始まる** |
| `databaseName` | `enme_prod` で**始まる** |
| `databaseUser` | `enme_user` と**完全一致** |
| 候補数 | **ちょうど1件**（Exactly-one rule） |

候補件数による分岐:

| 候補 | DELETE | CREATE |
| --- | --- | --- |
| 0件（取得・解析・件数条件すべて正常） | なし | あり（create-only） |
| 1件 | あり（その1件のみ） | あり |
| 2件以上 | なし（STOP） | なし（STOP） |

**`databaseName` を前方一致にした理由:** 作成リクエストで `databaseName: "enme_prod"` を指定しても、
Render は実際には**サフィックスを付与した値**を割り当てる。Preflight 実測値は `enme_prod_39o0` であり、
完全一致では**実在する Enme DB を候補0件と誤判定**した（期限切れDBが削除されず残置される不整合）。

**`ownerId` について:** 一覧レスポンスに**存在しないことを実環境で確認**したため、
レスポンス側の必須条件にはしない。ただし `GET` の `?ownerId=...` フィルタは維持する。
万一レスポンスに存在して不一致なら、その要素は候補から除外する（安全側）。

**必須フィールド（欠落・null・空・非文字列は「候補0件」ではなく STOP）:**
`id`（exit 15）／ `name`（exit 16）／ `databaseName`（exit 34）／ `databaseUser`（exit 35）

`databaseName` / `databaseUser` は実環境で存在が確認されたため、
**「フィールドが無いので条件を無視する」という optional 扱いは廃止**した。

## R7 — env-vars 更新の不変条件

ローカル資料で確認できる API は `GET` / `PUT /services/{id}/env-vars` のみであり、
**個別更新方式は確認できない**ため、全体 PUT を以下の不変条件付きで実施する。
1つでも満たせなければ **PUT せず exit 28**。

- GET 成功 ／ JSON 解析成功 ／ 配列であること ／ 空でないこと
- 全 entry の key が文字列かつ非空
- 全 entry に value フィールドが存在し、null でなく文字列であること
- key の重複なし
- `DATABASE_URL` が既存一覧に存在すること
- entry 数が更新前後で一致
- key の並びと集合が更新前後で完全一致
- `DATABASE_URL` 以外の value が更新前後で完全一致
- 変更箇所がちょうど1つで、それが `DATABASE_URL` の value であること

## deploy 監視

| 項目 | 値 |
| --- | --- |
| poll 間隔 | 10 秒 |
| 監視上限 | **3000 秒（50 分）** — `DEPLOY_MAX_ATTEMPTS=300` × `DEPLOY_POLL_SEC=10` |
| 無限待機 | **しない**（上限到達で exit 43） |

**判別する終端状態:**

| status | 扱い | exit | health check |
| --- | --- | --- | --- |
| `live` | 成功 | — | **実施する** |
| `build_failed` / `update_failed` / `pre_deploy_failed` | 失敗 | 41 | **実施しない** |
| `canceled` / `cancelled` | キャンセル | 42 | **実施しない** |
| 上限到達 | タイムアウト | 43 | **実施しない** |

### 監視上限を 3000 秒にした根拠

**Production Recovery 2026-09-12 実測：deploy に約35分（開始 `00:29:50Z` → 完了 `01:04:39Z`）を要した。
従来の 600 秒（10分）では正常な deploy でも timeout（exit 43）となったため、3000 秒（50分）へ変更した。**

- 実測 約35分 に対し **約15分のバッファ**
- 1800 秒（30分）では実測値を下回るため不十分
- 2400 秒（40分）ではバッファが約5分しかない
- ビルド内容（`bundle install` → `yarn install` → `webpacker:compile` → `assets:precompile`
  → `db:migrate` → `db:seed`（195店舗 / 585メニューの Cloudinary 画像添付を含む）
  → `images:attach_missing`）が free プランでは長時間を要するため

**health check の retry 設計（最大10回・線形バックオフ）は変更していない。**
health check は deploy が `live` になった後にのみ開始されるため、
deploy 所要時間を理由に retry 回数を増やす必要はない。

## health check

**deploy 完了だけでは SUCCESS にしない。** 以下すべてが必要。

| 確認 | 対象 | 判定 |
| --- | --- | --- |
| health endpoint | `/health` | HTTP 200 かつ本文に `ok` |
| DB 到達性 | `/`（`Restaurant` を検索するため DB 依存） | HTTP 200 |
| DB 行の描画 | 同上 | 本文に `top-card__name` が存在 |

`/` は DB 到達可能でも未 seed なら 200 を返すため、**HTTP status だけでは不十分**。
最大 10 回・線形バックオフで retry し、**無限 retry はしない**。

## exit code

| code | 意味 |
| --- | --- |
| 2 | 引数エラー（不明 / 重複 / 過多 / 排他違反） |
| 3 | 非対話実行で明示フラグがない |
| 10 | API 取得失敗（サービス情報 / DB一覧） |
| 11, 12, 14, 15, 16 | レスポンス解析失敗・形式異常・必須フィールド欠落・空値 |
| 13 | 取得件数が上限到達（pagination 未保証） |
| 18 | Enme DB 候補が2件以上 |
| 34 | `databaseName` 欠落 / null / 空 / 非文字列 |
| 35 | `databaseUser` 欠落 / null / 空 / 非文字列 |
| 19 | 候補情報を確定できない |
| 20 | 対象 DB の DELETE 失敗 |
| 21 | cleanup 失敗（成功として扱わない） |
| 22 | 現在の buildCommand を確認できない |
| 23 | buildCommand が `bin/render-build.sh` を参照していない |
| 24 | 環境変数一覧の取得失敗 |
| 25, 26, 27 | DB作成 / 準備待機 / 接続情報取得の失敗 |
| 28 | **R7 不変条件の違反（PUT しない）** |
| 29 | DATABASE_URL の PUT 失敗 |
| 30, 31, 32, 33 | Case B policy marker の異常（解析失敗 / 未設定 / 空 / 不一致） |
| 40 | deploy 起動失敗 / deploy ID 取得失敗 |
| 41 | deploy 失敗（build_failed / update_failed / pre_deploy_failed） |
| 42 | deploy キャンセル |
| 43 | deploy タイムアウト（監視上限 3000 秒 = 50 分を超過） |
| 50 | health endpoint 異常 |
| 51 | DB依存ページ異常（DB 到達不能） |
| 52 | DB依存ページは応答するが DB 行が描画されない（seed 未反映） |
| 60 | automatic mode でログを初期化できない |
| 61 | wrapper 判定: 本体が無言終了（summary 未記録） |

## ログ

| 項目 | 内容 |
| --- | --- |
| 実行ログ | `~/Library/Logs/Enme/recreate_db_runs.log`（**リポジトリ外**） |
| wrapper ログ | `~/Library/Logs/Enme/recreate_db_wrapper.log` |
| 権限 | 600 |
| ローテーション | 1MB 超で `.1` へ退避（各1世代） |
| 記録内容 | run ID / mode / 開始・終了日時 / Case B guard / 候補数 / DELETE / CREATE / env切替 / deploy / health check / 通知失敗 / SUCCESS-FAILURE / exit code / 1行 summary |
| 記録しないもの | API key ／ DATABASE_URL ／ connection string ／ password ／ Render env の値 |

launchd plist の `StandardOutPath` / `StandardErrorPath` が `scripts/` 配下を指すため、
`.gitignore` で `/scripts/*.log` と `/scripts/*.log.*` を除外している。

## 通知

- automatic mode では**成功・失敗のいずれでも必ず通知**する（`on_exit` で実行）
- 成功: タイトル `Enme DB自動再作成 SUCCESS` ／ 実行日時 ／ run ID
- 失敗: タイトル `Enme DB自動再作成 FAILED` ／ exit code ／ run ID ／ ログの確認先
- dry-run / manual では通知しない
- **通知失敗は結果判定を変えない**（ログに `notify_failed=1` を記録し、失敗を成功にしない）
- **個人情報はコードに書かない。** カレンダー記録は `ENME_NOTIFY_CALENDAR` が設定されている場合のみ行う
  （`.env` 等の非コミット領域で設定。未設定ならカレンダー記録はしない）
- `scripts/recreate_db_notify.sh` は薄い launchd エントリポイントであり、
  本体が trap へ到達できず summary を残さなかった場合に**最終防衛ラインとして通知**する

## 自動運用について

launchd の定期実行は **bootout + disable 済み**（Safety Hold 中）。

再有効化の前提:

1. Render 側に Case B policy marker を設定する
2. buildCommand が `bin/render-build.sh` を参照していることを確認する
3. dry-run で計画を確認する
4. end-to-end の自動再作成テストを実施する
5. launchd の実行実績を確認する

これらが**すべて完了するまで `launchctl enable` / `bootstrap` を行わない。**
