import 'dart:async';
import 'package:flutter_weather_bg/flutter_weather_bg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather_bg/bg/weather_bg.dart';
import 'package:flutter_weather_bg/utils/weather_type.dart';
import 'package:weather/weather.dart';
import 'package:flutter/services.dart';
import 'alarm.dart';
import 'lights.dart';
import 'package:screen/screen.dart';

WeatherType currentWeather = WeatherType.lightRainy;

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new homeScreen(),
  ));
}

class homeScreen extends StatefulWidget {
  @override
  homeScreenState createState() => new homeScreenState();

}



class homeScreenState extends State<homeScreen>{

  var changeBrightness;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);


    setState(() {
      fetchClimate();
    });
    const refreshRate = const Duration(minutes:1);
    new Timer.periodic(refreshRate, (Timer t) => fetchClimate());

    //Check if btDevice is in storage
    // checkBT();

    changeBrightness = 0;
  }

  // checkBT() async {
  //
  // }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        backgroundColor: Color.fromRGBO(16, 24, 32, 1),
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
          child: Row(
            //change
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              //left half of screen
              Container(
                  child: Stack(
                    children: [

                      WeatherBg(
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.height,
                        weatherType: currentWeather,
                      ),



                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Container(
                                    //change: left: 80
                                    padding: EdgeInsets.only(left: 140,top: 70),
                                    child: AnalogClock(
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      width: 300.0,
                                      showTicks: true,
                                      showNumbers: true,
                                      showDigitalClock: false,
                                      datetime: DateTime.now(),
                                      key: GlobalObjectKey(1),
                                      isLive:true,
                                    ),
                                  )
                              ),


                              Container(
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  child: Container(
                                    width: 200,
                                    height: 70,
                                    child: ButtonTheme(
                                      child: FutureBuilder<Widget>(
                                          future: fetchTemp(),
                                          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
                                            if(snapshot.hasData)
                                              return Center(child: snapshot.data,);

                                            return Container(child: Text('Loading...'));
                                          }
                                      ),

                                    ),
                                    color: Color.fromRGBO(46, 49, 49, 1),
                                  ),
                                ),
                                //change: left:80
                                padding: EdgeInsets.only(bottom: 80,left: 140),
                              ),


                            ],
                          ),



                          Container(
                            height: MediaQuery.of(context).size.height,
                            //change: 140
                            width: 220,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  //change .1,.4
                                  stops: [0.3,0.6],
                                  colors: [
                                    Color.fromRGBO(16, 24, 32, 1),
                                    Colors.transparent
                                  ],

                                )
                            ),
                          ),


                        ],
                      ),

                    ],
                  )
              ),






              //right half of screen

              Container(

                  child: Row(

                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

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

                                        Center(child: Image.asset('images/alarm.png',

                                          scale: 1.8,
                                        ),),

                                        Text('Alarm', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)

                                      ],
                                    ),
                                    onPressed: (){

                                      Navigator.push(context,MaterialPageRoute(builder: (context) => alarmState()));

                                    },
                                  ),
                                ),
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.only(right: 20,bottom: 20),
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

                                          scale: 1.8,
                                        ),),

                                        Text('Music', style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),)

                                      ],
                                    ),
                                    onPressed: (){
                                      Fluttertoast.showToast(
                                          msg: currentWeather.toString(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    },
                                  ),

                                ),
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.only(right: 20),
                          )


                        ],
                      ),


                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

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

                                        Center(child: Image.asset('images/rgbIcon.jpg',
                                          fit: BoxFit.fitWidth,
                                        ),),

                                        Text('Lights', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)

                                      ],
                                    ),
                                    onPressed: (){

                                      Navigator.push(context,MaterialPageRoute(builder: (context) => lightsState()));

                                    },
                                  ),
                                ),
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.only(bottom: 20),
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

                                        Center(child: Image.asset('images/blindsDown.png',
                                          fit: BoxFit.fitWidth,
                                        ),),

                                        Text('Blinds', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)

                                      ],
                                    ),
                                    onPressed: (){

                                      Navigator.push(context,MaterialPageRoute(builder: (context) => lightsState()));

                                    },
                                  ),
                                ),
                                color: Colors.white,
                              ),
                            ),
                          ),


                        ],
                      ),


                    ],

                  )
              )

            ],
          ),
        )
    );


  }


  Future<Widget> fetchTemp() async {
    //return text

    WeatherFactory wf = new WeatherFactory("a8c30e87533ee45e8af3311888feca27");
    Weather w = await wf.currentWeatherByLocation(33.883389,-117.443893);
    int formattedTemp = w.temperature.fahrenheit.round();

    return Text(formattedTemp.toString() + '\u2109',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),);
  }

  equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }


  fetchClimate() async {
    //return WeatherType.sunny
    //if time is after 5:30 then switch into night backgrounds

    WeatherFactory wf = new WeatherFactory("a8c30e87533ee45e8af3311888feca27");
    Weather w = await wf.currentWeatherByLocation(33.883389,-117.443893);

    String weatherBackground = w.weatherMain.toString();

    print(weatherBackground);

    DateFormat dateFormat = DateFormat("HH:mm:ss");
    DateTime sunsetDate = dateFormat.parse("19:10:00");
    DateTime sunriseDate = dateFormat.parse("8:00:00");
    String string = dateFormat.format(DateTime.now());

    DateTime formattedNow = dateFormat.parse(string);

    print(string);

    if(formattedNow.isBefore(sunsetDate) && formattedNow.isAfter(sunriseDate)){


      //daytime
      if(equalsIgnoreCase(weatherBackground,'clear')){
        currentWeather = WeatherType.sunny;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'dust')){
        currentWeather = WeatherType.dusty;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'smoke')){
        currentWeather = WeatherType.overcast;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'clouds')){
        currentWeather = WeatherType.cloudy;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'drizzle')){
        currentWeather = WeatherType.lightRainy;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'rain')){
        currentWeather = WeatherType.heavyRainy;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'thunderstorm')){
        currentWeather = WeatherType.thunder;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'snow')){
        currentWeather = WeatherType.heavySnow;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'mist')){
        currentWeather = WeatherType.foggy;
        setState(() {
      });
      return currentWeather;
      }else{
        currentWeather = WeatherType.cloudy;
        setState(() {
      });
      return currentWeather;
      }
    }else{

      //night time
      if(equalsIgnoreCase(weatherBackground,'clear')){
        currentWeather = WeatherType.sunnyNight;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'dust')){
        currentWeather = WeatherType.dusty;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'smoke')){
        currentWeather = WeatherType.overcast;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'clouds')){
        currentWeather = WeatherType.cloudyNight;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'drizzle')){
        currentWeather = WeatherType.lightRainy;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'rain')){
        currentWeather = WeatherType.heavyRainy;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'thunderstorm')){
        currentWeather = WeatherType.thunder;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'snow')){
        currentWeather = WeatherType.heavySnow;
        setState(() {
      });
      return currentWeather;
      }else if(equalsIgnoreCase(weatherBackground,'mist')){
        currentWeather = WeatherType.foggy;
        setState(() {
      });
      return currentWeather;
      }else{
        currentWeather = WeatherType.cloudyNight;
        setState(() {
      });

      return currentWeather;
      }
    }


  }


}



