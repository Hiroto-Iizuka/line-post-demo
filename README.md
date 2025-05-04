# README

LINE投稿のデモアプリ

dockerを起動し、ngrokで公開

```
> docker compose up
> ngrok http 3000
```

ngrok起動後にコンソールに表示される`Forwarding`のURLをLINE DevelopersのWebhook URLに設定することで、LINE上でメッセージを送れば質問を飛ばしてくれる。
