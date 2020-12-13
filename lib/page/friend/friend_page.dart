import 'package:fim/dao/recent_contact_dao.dart';
import 'package:fim/data/friends.dart';
import 'package:fim/data/preferences.dart';
import 'package:fim/data/stream.dart';
import 'package:fim/model/message.dart';
import 'package:fim/net/api.dart';
import 'package:fim/pb/logic.ext.pb.dart';
import 'package:fim/theme/color.dart';
import 'package:fim/theme/size.dart';
import 'package:fim/util/toast.dart';
import 'package:fim/widget/commit_button.dart';
import 'package:fim/widget/edit_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/services.dart';

class FriendPage extends StatefulWidget {
  Friend friend;
  String changeName;

  FriendPage({Key key, Int64 friendId}) : super(key: key) {
    friend = Friends.get(friendId);
  }

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  TextEditingController editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    editingController.text = widget.friend.remarks;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          brightness: appBarBrightness,
        ),
        body: Container(
          color: backgroundColor,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 90,
                padding: EdgeInsets.only(left: 45),
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.friend.avatarUrl,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(left: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              widget.friend.nickname,
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              "手机号：${widget.friend.phoneNumber}",
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 5,
              ),
              EditItem(
                title: "备注",
                hintText: "请填写备注",
                controller: editingController,
              ),
              Container(
                height: 10,
              ),
              CommitButton(
                text: "完成",
                onPressed: onCommit,
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, widget.changeName);
        return false;
      },
    );
  }

  Widget nicknameWidget() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 30, right: 30),
      height: 50,
      child: Row(
        children: [
          Text("备注", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                controller: editingController,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(15) //限制长度
                ],
                autofocus: false,
                decoration: InputDecoration(
                  hintText: "请填写备注",
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
                //controller: remarksController,
              ),
            ),
          )
        ],
      ),
    );
  }

  void onCommit() async {
    var req = SetFriendReq();
    req.friendId = widget.friend.userId;
    req.remarks = editingController.text;

    await logicClient.setFriend(req, options: getOptions());
    widget.friend.remarks = editingController.text;
    friendsChangeController.add(1);

    String name;
    if (editingController.text != "") {
      name = editingController.text;
    } else {
      name = widget.friend.nickname;
    }
    await RecentContactDao.updateInfo(Message.objectTypeUser,
        widget.friend.userId.toInt(), name, widget.friend.avatarUrl);
    friendsChangeController.add(1);
    widget.changeName = name;
    toast("修改成功");
  }
}
