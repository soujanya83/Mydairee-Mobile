import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/resourcesapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
// Create this new widget class:
class CommentsDialog extends StatefulWidget {
  final String resourceId;
  
  const CommentsDialog({Key? key, required this.resourceId}) : super(key: key);

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  List<dynamic>? comments;
  List<Map<String, dynamic>> mentionUser = [];
  bool mChildFetched = false;
  final GlobalKey<FlutterMentionsState> addCommentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch mention users
    final usersHandler = ObservationsAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE
    });
    
    final users = await usersHandler.getUsersList();
    final usersList = users['UsersList'];
    
    mentionUser = [];
    if (usersList is List) {
      for (final user in usersList) {
        if (user['type'] == 'Staff') {
          mentionUser.add({
            ...user,
            'display': user['name']
          });
        }
      }
      mChildFetched = true;
    }

    // Fetch comments
    final commentsHandler = ResourceAPIHandler({
      'userid': MyApp.LOGIN_ID_VALUE,
      'resourceId': widget.resourceId
    });

    final data = await commentsHandler.getCommentsList();
    
    if (!data.containsKey('error')) {
      setState(() {
        comments = data['commentsList'];
      });
    } else {
      MyApp.ShowToast(data['error'].toString(), context);
    }
  }

  Future<void> _addComment() async {
    final markup = addCommentKey.currentState?.controller?.markupText ?? '';
    var processedComment = markup;

    for (final user in mentionUser) {
      if (markup.contains(user['name'])) {
        processedComment = processedComment.replaceAll(
          "@${user['name']}",
          '<a href="user_${user['type']}_${user['id']}">@${user['name']}</a>'
        );
      }
    }

    if (processedComment.isNotEmpty) {
      final handler = ResourceAPIHandler({
        'userid': MyApp.LOGIN_ID_VALUE,
        'resourceId': widget.resourceId,
        'comment': processedComment
      });
      
      final data = await handler.addComment();
      
      if (!data.containsKey('error')) {
        Navigator.pop(context, 'refresh');
      } else {
        MyApp.ShowToast(data['error'].toString(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          
          // Comments List
          Expanded(
            child: comments == null
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: comments!.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        title: Text(
                          comments![index]['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: tagRemove(
                            comments![index]['comment'],
                            'title',
                            '',
                            context
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1),
          
          // Add Comment
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: mChildFetched
                          ? FlutterMentions(
                              key: addCommentKey,
                              suggestionPosition: SuggestionPosition.Top,
                              minLines: 1,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              mentions: [
                                Mention(
                                  trigger: '@',
                                  style: TextStyle(color: Colors.blue),
                                  data: mentionUser,
                                  matchAll: false,
                                  suggestionBuilder: (data) => ListTile(
                                    title: Text(data['name']),
                                  ),
                                ),
                              ],
                            )
                          : TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Loading mentions...',
                              ),
                              enabled: false,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}