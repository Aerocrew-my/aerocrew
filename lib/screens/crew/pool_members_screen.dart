import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class PoolMembersScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const PoolMembersScreen({super.key, required this.trip});

  @override
  State<PoolMembersScreen> createState() => _PoolMembersScreenState();
}

class _PoolMembersScreenState extends State<PoolMembersScreen> {
  final messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Siti Nabilah',
      'initials': 'SN',
      'message': 'Good morning everyone! 😊',
      'time': '02:45',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'initials': 'FZ',
      'message': 'Morning! Ready at PJ gate.',
      'time': '02:47',
      'isMe': true,
    },
    {
      'sender': 'Razif Azman',
      'initials': 'RA',
      'message': 'Ahmad just messaged me, ETA 8 mins to first stop',
      'time': '02:52',
      'isMe': false,
    },
  ];

  final poolMembers = [
    {
      'name': 'Faiz Zakaria',
      'initials': 'FZ',
      'airline': 'AirAsia',
      'zone': 'Petaling Jaya',
      'pickup': '03:00',
      'status': 'ready',
      'isMe': true,
    },
    {
      'name': 'Siti Nabilah',
      'initials': 'SN',
      'airline': 'AirAsia',
      'zone': 'Ara Damansara',
      'pickup': '03:20',
      'status': 'ready',
      'isMe': false,
    },
    {
      'name': 'Razif Azman',
      'initials': 'RA',
      'airline': 'Malaysia Airlines',
      'zone': 'Subang Jaya',
      'pickup': '03:40',
      'status': 'waiting',
      'isMe': false,
    },
  ];

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: selectedTab == 0 ? _buildMembersList() : _buildGroupChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POOL GROUP',
                  style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.amber,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${poolMembers.length} crew · SZB 05:30',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              ...poolMembers.asMap().entries.map(
                (e) => Positioned(
                  left: e.key * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AeroColors.navy, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        e.value['initials'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: poolMembers.length * 20.0 + 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AeroColors.navyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AeroColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedTab == 0
                        ? AeroColors.amber
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: selectedTab == 0
                            ? Colors.white
                            : AeroColors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedTab == 0
                              ? Colors.white
                              : AeroColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedTab == 1
                        ? AeroColors.amber
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: selectedTab == 1
                            ? Colors.white
                            : AeroColors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Group chat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedTab == 1
                              ? Colors.white
                              : AeroColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AeroColors.navyCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AeroColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AeroColors.amberLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AeroColors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmad Hassan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Toyota Hiace · WXY 1234 · Driver',
                      style: TextStyle(fontSize: 11, color: AeroColors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AeroColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: AeroColors.success),
                    SizedBox(width: 4),
                    Text(
                      'En route',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AeroColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('CREW MEMBERS', style: AeroText.label),
        const SizedBox(height: 8),
        ...poolMembers.map(
          (member) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: member['isMe'] == true
                  ? AeroColors.amber.withValues(alpha: 0.06)
                  : AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: member['isMe'] == true
                    ? AeroColors.amber.withValues(alpha: 0.2)
                    : AeroColors.divider,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AeroColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      member['initials'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.amber,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member['name'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (member['isMe'] == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AeroColors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AeroColors.amber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${member['airline']} · ${member['zone']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AeroColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pickup ${member['pickup']}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AeroColors.amber,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: member['status'] == 'ready'
                            ? AeroColors.success.withValues(alpha: 0.1)
                            : AeroColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member['status'] == 'ready' ? 'Ready' : 'Waiting',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: member['status'] == 'ready'
                              ? AeroColors.success
                              : AeroColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChat() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final msg = messages[i];
              final isMe = msg['isMe'] as bool;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 3),
                          child: Text(
                            msg['sender'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AeroColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AeroColors.amber : AeroColors.navyCard,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                          border: isMe
                              ? null
                              : Border.all(
                                  color: AeroColors.divider,
                                  width: 0.5,
                                ),
                        ),
                        child: Text(
                          msg['message'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isMe ? Colors.white : AeroColors.greyLight,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                          left: 4,
                          right: 4,
                        ),
                        child: Text(
                          msg['time'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AeroColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: AeroColors.navyCard,
            border: Border(
              top: BorderSide(color: AeroColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Message the group...',
                    hintStyle: const TextStyle(
                      color: AeroColors.grey,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AeroColors.navy,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AeroColors.divider,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AeroColors.divider,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AeroColors.amber,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (messageController.text.trim().isEmpty) {
                    return;
                  }
                  setState(() {
                    messages.add({
                      'sender': 'Me',
                      'initials': 'FZ',
                      'message': messageController.text.trim(),
                      'time': TimeOfDay.now().format(context),
                      'isMe': true,
                    });
                    messageController.clear();
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AeroColors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
