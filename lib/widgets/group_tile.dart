import 'package:fyp_app/pages/test_page.dart';
import 'package:fyp_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        margin: const EdgeInsets.fromLTRB(60, 5, 60, 5), // Side margins
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, // Using the primary color
          border: Border.all(
              color: Colors.grey[400]!, width: 1), // Border color and width
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white, // Change to contrast primary color
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .primaryColor, // Text color matches the container's original color
                  fontWeight: FontWeight.w500,
                  fontSize: 24, // Font size for the icon's text
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.groupName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, // White text for better readability
                fontWeight: FontWeight.bold,
                fontSize: 18, // Font size for the title
              ),
            ),
            Text(
              "Click to access",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, // White text for subtitles
                fontSize: 15, // Font size for the subtitle
              ),
            ),
          ],
        ),
      ),
    );
  }
}
