
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class testingState extends StatefulWidget {
  @override
  testing createState() => new testing();
}

class testing extends State<testingState>{

  @override
  void initState() {
    super.initState();

  }


  // update time till alarm every minute


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body:  Row(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20,top: 10,bottom: 10),
            child: FlatButton(
              child: Icon(Icons.arrow_back_ios,color: Colors.white,size: 50,),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 10,left: 300,bottom: 10),
            child: Image.asset('images/alarm.png', fit: BoxFit.fitWidth, scale: 6,),
          ),

          Container(
            padding: EdgeInsets.only(top: 10,bottom: 10),
            child: Text('testing',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
          ),


        ],
      ),
    );
  }

}