import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:slider_button/slider_button.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:screen/screen.dart';


class alarmState extends StatefulWidget {
  @override
  alarmScreen createState() => new alarmScreen();
}

class alarmScreen extends State<alarmState>{

  int x = 0;

  IconData power = Icons.power_off;
  Color powerColor = Colors.red;

  Color borderColor = Color(0xff15fff1);

  Color dialogPickerColor=Colors.red;

  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);



  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  var changeBrightness=0;
  @override
  void initState() {
    super.initState();

  }


  // update time till alarm every minute


  @override
  Widget build(BuildContext context) {




    // TODO: implement build
    return Scaffold(

        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              setState(() {
                changeBrightness++;
                if(changeBrightness%2==0){
                  Screen.setBrightness(1);
                }else{
                  Screen.setBrightness(.05);
                }
              });
            },
          child: Container(
            child: Column(
              children: [

                //appbar
                Row(
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
                      child: Text('Alarm',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10,left: 300,bottom: 10),
                      child: LiteRollingSwitch(
                        //initial value
                        value: true,
                        textOn: 'On',
                        textOff: 'Off',
                        colorOn: Colors.greenAccent[700],
                        colorOff: Colors.redAccent[700],
                        iconOn: Icons.done,
                        iconOff: Icons.remove_circle_outline,
                        textSize: 16.0,
                        onChanged: (bool state) {
                          //Use it to manage the different states
                          print(state);
                        },
                      ),
                    ),


                  ],
                ),




                //main body

                Expanded(
                    child: Stack(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              tileMode: TileMode.mirror,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xb2da2525),
                                Color(0xff215bf3),
                              ],
                              stops: [
                                0,
                                1,
                              ],
                            ),
                            backgroundBlendMode: BlendMode.srcOver,
                          ),
                          child: PlasmaRenderer(
                            type: PlasmaType.infinity,
                            particles: 10,
                            color: Color(0x44e45a23),
                            blur: 0.1,
                            size: 1,
                            speed: 1,
                            offset: 0,
                            blendMode: BlendMode.plus,
                            variation1: 0,
                            variation2: 0,
                            variation3: 0,
                            rotation: -0.0,
                          ),
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            //left side of screen
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(40.0),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [

                                        Column(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'T',
                                                style: TextStyle(fontSize: 40),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: "he Next Alar",
                                                      style: TextStyle(
                                                          decoration: TextDecoration.underline,
                                                          fontSize: 40
                                                      )),

                                                  TextSpan(
                                                      text: "m",
                                                      style: TextStyle(
                                                          fontSize: 40
                                                      )),

                                                ],
                                              ),
                                            ),


                                            Container(
                                              padding: EdgeInsets.fromLTRB(0, 20, 0,0),
                                              child: FutureBuilder<Widget>(
                                                  future: getStoredAlarm(),
                                                  builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
                                                    if(snapshot.hasData)
                                                      return snapshot.data;

                                                    return Container(child: CircularProgressIndicator());
                                                  }
                                              ),
                                            )


                                          ],
                                        ),




                                        Column(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'T',
                                                style: TextStyle(fontSize: 40),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: "ime Till Alar",
                                                      style: TextStyle(
                                                          decoration: TextDecoration.underline,
                                                          fontSize: 40
                                                      )),

                                                  TextSpan(
                                                      text: "m",
                                                      style: TextStyle(
                                                          fontSize: 40
                                                      )),


                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding: EdgeInsets.fromLTRB(0, 20, 0,0),
                                              child: FutureBuilder<Widget>(
                                                  future: getCountdownWidget(),
                                                  builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
                                                    snapshot.data;
                                                    if(snapshot.hasData)
                                                      return snapshot.data;

                                                    return Container(child: CircularProgressIndicator());
                                                  }
                                              ),
                                              // child: Text("13 HRS\n46 MINS\n18 SECS",style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),),
                                            )


                                          ],
                                        ),

                                      ],
                                    ),
                                  )
                              ),
                            ),





                            //right side of the screen

                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                                  child: ClipRRect(
                                    borderRadius: new BorderRadius.circular(40.0),
                                    child: Container(
                                      width: 230,
                                      height: 230,
                                      child: ButtonTheme(
                                        child: FlatButton(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              Center(child: Image.asset('images/setAlarm.png',
                                                scale: 3,
                                              ),),

                                              Container(
                                                child: Text('Set Alarm Time', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                              )

                                            ],
                                          ),
                                          onPressed: (){
                                            Navigator.of(context).push(
                                              showPicker(
                                                context: context,
                                                value: _time,
                                                onChange: storeAlarm,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),



                                Container(

                                  child: ClipRRect(
                                    borderRadius: new BorderRadius.circular(40.0),
                                    child: Container(
                                      width: 230,
                                      height: 230,
                                      child: ButtonTheme(
                                        child: FlatButton(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              Center(child: Image.asset('images/musicIcon.png',
                                                scale: 6,
                                              ),),

                                              Container(
                                                child: Text('Change Alarm Sound', style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                              )

                                            ],
                                          ),
                                          onPressed: (){

                                            //show list tile
                                            changeMusic(context);
                                          },
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),




                              ],
                            )


                          ],
                        ),



                      ],
                    )
                )



              ],
            ),
          ),
        )
    );
  }

  Future<Widget> getStoredAlarm() async{
    //gets path of document
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //returns 0 if alarm doesn't exist
    final storedAlarm = prefs.getString('storedAlarm') ?? 0;

    //returns text box
    return Text(storedAlarm,style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),);
  }



  storeAlarm(newStoredAlarm) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('newStoredAlarmHour', newStoredAlarm.hour.toString());
    prefs.setString('newStoredAlarmMinute', newStoredAlarm.minute.toString());

    print("new Stored Alarm : " + newStoredAlarm.minute.toString());

    //convert newStoredAlarm to string
    final now = new DateTime.now();
    final chosenTime = DateTime(now.year, now.month, now.day, newStoredAlarm.hour, newStoredAlarm.minute);
    final format = DateFormat.jm();  //"6:00 AM"

    prefs.setString('storedAlarm', format.format(chosenTime));



    //calculate countdown value

    final currentTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);


    var countDown;
    //dt gives chosen time in DateTime format

    if(chosenTime.isBefore(currentTime)){
      //add 24hrs to alarmTime so calculation doesn't lead to negative time
      var newChosenTime = chosenTime.add(new Duration(hours: 24));

      countDown = newChosenTime.difference(currentTime);
    }else{
      countDown = chosenTime.difference(currentTime);
    }

    //store countdown

    prefs.setString('storedCount', countDown.toString());


    setState(() {
      getStoredAlarm();
      getCountdownWidget();
    });
  }



  Future<Widget> getCountdownWidget() async {


    //TODO: get string from storage, find out how many seconds that string equals to, then add it to endTime

    //gets path of document
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final chosenMusic = prefs.getString('chosenMusic') ?? 0;

    final storedAlarmHour = prefs.getString('newStoredAlarmHour') ?? 0;
    int storedAlarmIntH = int.parse(storedAlarmHour.toString());

    final storedAlarmMinute= prefs.getString('newStoredAlarmMinute') ?? 0;
    int storedAlarmIntM = int.parse(storedAlarmMinute.toString());

    final now = new DateTime.now();
    final chosenTime = DateTime(now.year, now.month, now.day, storedAlarmIntH, storedAlarmIntM);
    final format = DateFormat.jm();  //"6:00 AM"

    final currentTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);

    var countDown;
    //dt gives chosen time in DateTime format

    if(chosenTime.isBefore(currentTime)){
      //add 24hrs to alarmTime so calculation doesn't lead to negative time
      var newChosenTime = chosenTime.add(new Duration(hours: 24));

      countDown = newChosenTime.difference(currentTime);
    }else{
      countDown = chosenTime.difference(currentTime);
    }


    String storedAlarmString = countDown.toString();
    print(storedAlarmString);
    String hours="";
    String minutes="";
    String seconds="";
    List<String>charArray;
    int previousColon;
    int secondColon;
    bool hoursDone = false;
    bool minsDone = false;

    for(int i =0; i<storedAlarmString.length; i++){

      if(storedAlarmString[i]==":"&& !hoursDone){
        previousColon = i;
        for(int j=0; j<i;j++){
          hours+=storedAlarmString[j];
        }
        hoursDone = true;
      }else if(storedAlarmString[i]==":"&& hoursDone){
        secondColon = i;
        for(int j=previousColon+1; j<i;j++){
          minutes+=storedAlarmString[j];
        }
        minsDone = true;
      }else if(storedAlarmString[i]=="."&&minsDone){
        for(int j=secondColon+1; j<i;j++){
          seconds+=storedAlarmString[j];
        }
      }

    }


    int intHours = int.parse(hours);
    int intMins = int.parse(minutes);
    int intSeconds = int.parse(seconds);

    int hoursInSeconds = intHours*3600;
    int minsInSeconds = intMins*60;

    int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * (hoursInSeconds+minsInSeconds+intSeconds);



    return CountdownTimer(
      endTime: endTime,
      widgetBuilder: (_, CurrentRemainingTime time) {
        if (time == null) {
          //have the hub play some sound
          final assetsAudioPlayer = AssetsAudioPlayer();

          try {
            assetsAudioPlayer.open(
              //TODO: use sound stored from alarmSounds array
              Audio(chosenMusic),
            );
          } catch (t) {
            //mp3 unreachable
          }

          //show slider to turn off alarm
          return SliderButton(
            action: () {
              assetsAudioPlayer.pause();
              Navigator.of(context).pop();
            },
            label: Text(
              "I'm Awake",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 23),
            ),
            icon: Text(
              "x",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 44,
              ),
            ),


          );
        }

        //prevent time.hours from showing null
        String timeHours;
        String timeMins;

        if(time.hours==null){
          timeHours= "0";
        }else{
          timeHours= time.hours.toString();
        }

        if(time.min==null){
          timeMins= "0";
        }else{
          timeMins= time.min.toString();
        }

        return Text(
            timeHours + " HRS\n" + timeMins + " MINS\n${time.sec} SECS",style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold)
        );
      },
    );
  }



  changeMusic(BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text("Choose a Song",style: TextStyle(color: Colors.white,fontSize: 30),),
      content: Container(
        height: 1200,
        width: 500,
        child: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Image(image: AssetImage('images/All_Mine.png'),),
                title: Text('All Mine',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                subtitle: Text('THEY'),
                trailing: FlatButton(
                  color: Colors.black,
                  child: Text("This Song",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    print("All Mine");
                    prefs.setString('chosenMusic', 'assets/audios/All_mine.mp3');
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Will play: All Mine",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 40.0
                    );
                  },
                ),
              ),
            ),


            Card(
              child: ListTile(
                leading: Image(image: AssetImage('images/City_Girls.png'),),
                title: Text('City Girls',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                subtitle: Text('Chris Brown, Young Thug'),
                trailing: FlatButton(
                  color: Colors.black,
                  child: Text("This Song",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    print("City Girls");
                    prefs.setString('chosenMusic', 'assets/audios/City_girls.mp3');
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Will play: City Girls",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 40.0
                    );
                  },
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Image(image: AssetImage('images/Deja_Vu.png'),),
                title: Text('Deja Vu',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                subtitle: Text('Post Malone, Justin Bieber'),
                trailing: FlatButton(
                  color: Colors.black,
                  child: Text("This Song",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    print("Deja Vu");
                    prefs.setString('chosenMusic', 'assets/audios/Deja_Vu.mp3');
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Will play: Deja Vu",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 40.0
                    );
                  },
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Image(image: AssetImage('images/Die_for_you.png'),),
                title: Text('Die For You',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                subtitle: Text('The Weeknd'),
                trailing: FlatButton(
                  color: Colors.black,
                  child: Text("This Song",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    print("Die for you");
                    prefs.setString('chosenMusic', 'assets/audios/Die_for_you.mp3');
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Will play: Die for you",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 40.0
                    );
                  },
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Image(image: AssetImage('images/Too_Late.png'),),
                title: Text('Too Late',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                subtitle: Text('The Weeknd'),
                trailing: FlatButton(
                  color: Colors.black,
                  child: Text("This Song",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    print("Too Late");
                    prefs.setString('chosenMusic', 'assets/audios/Too_late.mp3');
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Will play: Too Late",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 40.0
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}