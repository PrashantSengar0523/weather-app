import 'package:flutter/material.dart';
class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final String temp;
  const AdditionalInfo({
    super.key,
    required this.icon,
    required this.text,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
     children: [
       Padding(
         padding: const EdgeInsets.all(8.0),
         child:  Icon(icon,size: 30,),
       ),
        Padding(
         padding: const EdgeInsets.all(8.0),
         child:  Text(text,style: const TextStyle(
          fontSize: 15,
         ),),
       ),
       Padding(
         padding:  const EdgeInsets.all(8.0),
         child:  Text(temp.toString(),style: const TextStyle(
          fontSize: 18,
         ),),
       ),
     ],
                      );
  }
}