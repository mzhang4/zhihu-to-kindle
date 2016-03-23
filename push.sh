#! /bin/bash
WORK_DIR=/DIR
MOBI=$WORK_DIR/zhihu$(date "+%Y-%m-%d-%s").mobi
RECIPE=zhihu-daily.recipe
PROFILE=kindle_pw

KINDLEMAIL=example@kindle.com
BCC_MAIL=example@gmail.com
API_KEY=key-example
DOMAIN=example.mailgun.org
SENDER="postmaster@$DOMAIN"

pushd $WORK_DIR
ebook-convert $RECIPE $MOBI --output-profile kindle_pw 2>&1 | tee $MOBI.log
if [ $? -eq 0 ]; then
curl -s --user "api:$API_KEY" \
	https://api.mailgun.net/v3/$DOMAIN/messages \
		-F from="Example <$SENDER>" \
		-F to="Example <$KINDLEMAIL>" \
		-F bcc="Example <$BCC_MAIL>" \
		-F subject="[❤ 知乎日报] $(date '+%Y年 %m月 %d日 ') 发送成功" \
		-F text='今日的知乎日报推送成功。为了确保您的专刊推送，请将 $SENDER 加入白名单。' \
		-F attachment=@$MOBI
else
	curl -s --user "api:$API_KEY" \
		https://api.mailgun.net/v3/$DOMAIN/messages \
			-F from="Example <$SENDER>" \
			-F to="Example <$BCC_MAIL>" \
			-F subject="[❤ 知乎] $(date '+%Y年 %m月 %d日 ')错误报告" \
			-F text="今日的电子书推送并未成功，请查看附件的错误日志。为了确保您的专刊推送，请将 $SENDER 加入白名单。" \
			-F attachment=@$MOBI.log
	echo "Send Failure"
fi
rm *.mobi
rm *.log
popd