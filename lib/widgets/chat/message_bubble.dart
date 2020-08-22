import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(this.message, this.username, this.userImage, this.isMe,
      {this.key});

  final Key key;
  final String message;
  final String username;
  final String userImage;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              constraints: BoxConstraints(
                  maxWidth: widthOfScreen * 0.40,
                  minWidth: widthOfScreen * 0.2),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).backgroundColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 17,
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline1.color,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Positioned(
              top: -5,
              right: isMe ? null : -17,
              left: isMe ? -17 : null,
              child: ClipOval(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                    imageUrl: userImage,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ],
          overflow: Overflow.visible,
        ),
      ],
    );
  }
}
