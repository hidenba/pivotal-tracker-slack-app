PivotalTrackerの変更をSlackに通知するためのAWS Lambdaの関数です。

## 利用方法

予めECRのリポジトリを作成しておいてください。

### ECRにイメージをpush

```
$ docker build -t xxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/my-repository .
$ docker push xxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/my-repository
```

### AWS Lambdaの作成と設定

1. コンテナイメージで関数を作成してECRのイメージを選択して関数を作成
1. トリガーにAPIGatewayを追加

### SlackAPPの作成

SlackAPPを作成してIncoming Webhooksの設定をする

### PivotalTrackerのWebHookの設定

PivotalTrackerのWebHookにAPIGatewayのエンドポイントを設定する

### Lambdaの環境変数の設定

Lambdaの環境変数にSlackのエンドポイントを設定する

keyは `ID#{ProjectID}`とし`IDxxxxxx`になるように設定する
(#{ProjectID}をPivotalTrackerのProjectIDに置き換える)
valueはSlackのエンドポイントを設定する
