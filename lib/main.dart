import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter_weather_bg/flutter_weather_bg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather_bg/bg/weather_bg.dart';
import 'package:flutter_weather_bg/utils/weather_type.dart';
import 'package:weather/weather.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'alarm.dart';
import 'lights.dart';
import 'package:screen/screen.dart';

WeatherType currentWeather = WeatherType.lightRainy;

void main() {
  runApp(new MaterialApp(
    theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }
        )
    ),
    debugShowCheckedModeBanner: false,
    home: new homeScreen(),
  ));
}

class homeScreen extends StatefulWidget {
  @override
  homeScreenState createState() => new homeScreenState();

}



class homeScreenState extends State<homeScreen>{

  //BT VARS
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;


  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;






  var changeBrightness;
  var initial;
  var distance;

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


    // Get connection status
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        getPairedDevices();
      });
    });

  }


  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }


  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }



  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return new Scaffold(
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
          onPanStart: (DragStartDetails details) {
            initial = details.globalPosition.dy;
          },
          onPanUpdate: (DragUpdateDetails details) {
            distance= details.globalPosition.dy - initial;
          },
          onPanEnd: (DragEndDetails details) {
            initial = 0.0;
            if(distance<-200){
              //show bluetooth menu
              connectDeviceAlert(context);
            }
            //+ve distance signifies a drag from left to right(start to end)
            //-ve distance signifies a drag from right to left(end to start)
          },

          child: Container(
                  child: Stack(
                    children: [

                      WeatherBg(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        weatherType: currentWeather,
                      ),



                      Row(

                        children: [

                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container(
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
                                  padding: EdgeInsets.only(bottom: 80),
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
                                                //change: child: snapshot.data
                                                return Center(child: snapshot.data,);

                                              return Container(child: Text('Loading...'));
                                            }
                                        ),

                                      ),
                                      color: Color.fromRGBO(46, 49, 49, 1),
                                    ),
                                  ),
                                  //change: left:80
                                ),


                              ],
                            ),
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8, right: MediaQuery.of(context).size.width/10),
                          ),





                          //right half of screen

                          Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                      child: Container(
                                          color: Colors.grey.withOpacity(0.3),
                                          alignment: Alignment.center,
                                          child: Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,

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

                                                                    Center(
                                                                      child: Hero(
                                                                        child: Image.asset('images/alarm.png', scale: 1.8,),
                                                                        tag: 'alarm',
                                                                      )
                                                                      ),

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

                                                                    Center(
                                                                        child: Hero(
                                                                          child: Image.asset('images/rgbIcon.jpg', fit: BoxFit.fitWidth,),
                                                                          tag: 'lights',
                                                                        )
                                                                    ),

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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          )


                        ],


                      ),

                    ],
                  )
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




  //BT FUNCTIONS


  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }



  void _connect() async {
    if (_device == null) {
      //no device chosen
    } else {
      if (!isConnected) {
        //connecting
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;


          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });



        _sendOnMessageToBluetooth();
      }
    }
  }

  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("*" + "\r\n"));
    await connection.output.allSent;
  }


  connectDeviceAlert(BuildContext context) async {

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Choose a Device",style: TextStyle(color: Colors.black,fontSize: 30),),
      content: Container(
          height: 200,
          width: 500,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              DropdownButton(
                items: _getDeviceItems(),
                onChanged: (value) =>
                    setState(() => _device = value),
                value: _devicesList.isNotEmpty ? _device : null,
              ),

              FlatButton(
                color: Colors.black,
                onPressed: (){
                  _connect();
                  Navigator.pop(context);
                },
                child: Text('Connect',style: TextStyle(color: Colors.white),),
              ),

            ],
          )
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



