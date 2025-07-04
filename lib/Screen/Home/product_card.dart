// import 'package:flutter/material.dart';
//
// import '../../Model/product.dart';
//
// class ProductCard extends StatelessWidget {
//   final Product product;
//
//   const ProductCard({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: product.imageUrl != null
//                   ? Image.network(
//                 product.imageUrl!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                 const Icon(Icons.broken_image, size: 50),
//               )
//                   : Container(
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.image, size: 50),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '\$${product.price.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     color: Colors.deepPurple[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                       ),
//                       child: const Text('Order', style: TextStyle(fontSize: 12)),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                       ),
//                       child: const Text('Appointment', style: TextStyle(fontSize: 12)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }