// import 'package:flutter/material.dart';
// import 'package:social_feed_app/const/color_const.dart';

// class DashboardScreen extends StatefulWidget {
//   final String profileimage;
//   const DashboardScreen({super.key, required this.profileimage});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final screenwidth = MediaQuery.of(context).size.width;
//     final screenheight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: ColorConst.secondary,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: false,
//             floating: false,
//             expandedHeight: 300,
//             backgroundColor: ColorConst.secondary,
//             flexibleSpace: LayoutBuilder(
//               builder: (context, constraints) {
//                 // constraints.biggest.height gives current height of appbar
//                 final isCollapsed =
//                     constraints.biggest.height <= kToolbarHeight + 10;

//                 return Container(
//                   decoration: BoxDecoration(
//                     color: ColorConst.secondary,
//                     borderRadius: isCollapsed
//                         ? BorderRadius
//                               .zero // flat when collapsed
//                         : const BorderRadius.vertical(
//                             bottom: Radius.circular(60), // curve when expanded
//                           ),
//                   ),
//                   child: FlexibleSpaceBar(
//                     background: Center(
//                       child: SizedBox(
//                         height: 100,
//                         width: 200,
//                         child: Image.network(
//                           widget.profileimage,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(1.0),
//               child: Container(
//                 height: screenheight,
//                 width: screenwidth,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                   color: ColorConst.primary,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
