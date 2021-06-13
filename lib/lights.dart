import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'gradientText.dart';
import 'package:screen/screen.dart';


class lightsState extends StatefulWidget {
  @override
  lightsScreen createState() => new lightsScreen();
}

class lightsScreen extends State<lightsState>{

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
  bool _connected = false;
  bool _isButtonUnavailable = false;

  int x = 0;

  IconData power = Icons.power_off;
  Color powerColor = Colors.red;

  Color bluetoothColor = Colors.grey;

  Color borderColor = Color(0xff15fff1);

  Color backgroundColor1 = Color(0xff15fff1);

  Color dialogPickerColor=Colors.red;



  @override
  void initState() {
    super.initState();


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
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
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



  // For retrieving and storing the paired devices
  // in a list.
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

  var changeBrightness=0;

  //TODO: save value of power icon and bluetooth icon to storage

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // onDoubleTap: () {
          //   setState(() {
          //     changeBrightness++;
          //     if(changeBrightness%2==0){
          //       Screen.setBrightness(1);
          //     }else{
          //       Screen.setBrightness(.05);
          //     }
          //   });
          // },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: borderColor,width: 3)
            ),
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
                      child: Image.asset('images/rgbIcon.jpg', fit: BoxFit.fitWidth, scale: 27,),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10,bottom: 10),
                      child: Text('Lights',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                    ),

                    Container(
                        padding: EdgeInsets.only(top: 10,left: 200,bottom: 10),
                        child: FlatButton(
                          child: Icon(power,color: powerColor,size: 50,),
                          onPressed: (){
                            setState((){
                              if(x%2==0){
                                //on
                                //TODO: send on signal
                                power = Icons.power;
                                powerColor = Colors.green;
                              }else{
                                //off
                                //TODO: send off signal
                                power = Icons.power_off;
                                powerColor = Colors.red;
                              }

                              x++;
                            });
                          },
                        )
                    ),


                    Container(
                        padding: EdgeInsets.only(top: 10,left: 20,bottom: 10),
                        child: FlatButton(
                          child: Icon(Icons.bluetooth,color: bluetoothColor,size: 50,),
                          onPressed: (){
                            setState((){
                              if(x%2==0){
                                //on
                                //alert dialog with ability to choose bluetooth device
                                connectDeviceAlert(context);
                                bluetoothColor = Colors.blueAccent;
                              }else{
                                //off
                                //disconnect from bluetooth
                                _disconnect();
                                bluetoothColor = Colors.grey;
                              }

                              x++;
                            });
                          },
                        )
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
                              backgroundColor1,
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

                          //color wheel
                          Container(

                            child: CircleColorPicker(
                              initialColor: Color.fromARGB(1, 0, 78, 175),
                              onChanged: (color) => setState((){
                                //TODO: send value of color to arduino

                                String stringColor = color.toString();
                                String formattedColor = stringColor.substring(10,16);
                                //^^ color in hex ^^

                                //sending color to hc-06
                                _sendColor(formattedColor);

                                //format color to send as a hex value
                                borderColor = color;
                                backgroundColor1 = color;
                              }),
                              size: const Size(400, 400),
                              strokeWidth: 10,
                              thumbSize: 36,
                            ),
                          ),



                          //right half of lights screen
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(40.0),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                                color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //toggle lights by day time
                                    Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 20),
                                            child: Text('Toggle Lights by Time of Day',style: TextStyle(color: Colors.white,fontSize: 30),),
                                          ),

                                          Container(
                                            child: ToggleSwitch(
                                              minWidth: 130.0,
                                              minHeight: 80,
                                              initialLabelIndex: 1,
                                              cornerRadius: 20.0,
                                              activeFgColor: Colors.white,
                                              inactiveBgColor: Colors.grey,
                                              inactiveFgColor: Colors.white,
                                              labels: ['On', 'Off'],
                                              activeBgColors: [Colors.green, Colors.red],
                                              onToggle: (index) {
                                                if(index==1){
                                                  _sendOffMessageToBluetooth();
                                                }else if(index==0){
                                                  _sendOnMessageToBluetooth();
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),




                                    Container(

                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 20),
                                            child: GradientText(
                                              'Cycle colors',
                                              gradient: LinearGradient(colors: [
                                                Colors.red,
                                                Colors.pink,
                                                Colors.purple,
                                                Colors.deepPurple,
                                                Colors.deepPurple,
                                                Colors.indigo,
                                                Colors.blue,
                                                Colors.lightBlue,
                                                Colors.cyan,
                                                Colors.teal,
                                                Colors.green,
                                                Colors.lightGreen,
                                                Colors.lime,
                                                Colors.yellow,
                                                Colors.amber,
                                                Colors.orange,
                                                Colors.deepOrange,
                                              ]),
                                            ),
                                          ),

                                          Container(
                                            child: ToggleSwitch(
                                              minWidth: 130.0,
                                              minHeight: 80,
                                              initialLabelIndex: 1,
                                              cornerRadius: 20.0,
                                              activeFgColor: Colors.white,
                                              inactiveBgColor: Colors.grey,
                                              inactiveFgColor: Colors.white,
                                              labels: ['On', 'Off'],
                                              activeBgColors: [Colors.green, Colors.red],
                                              onToggle: (index) {
                                                if(index==0){
                                                  //rainbow time
                                                  rainbowMode();
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),





                                  ],
                                ),
                              ),
                            ),
                          )


                        ],
                      )
                    ],
                  ),
                )



              ],
            ),
          ),
        )
    );
  }

  rainbowMode() async{
    connection.output.add(utf8.encode("/" + "\r\n"));
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



  // Create the List of devices to be shown in Dropdown Menu
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

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      //no device chosen
    } else {
      if (!isConnected) {
        //connecting
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

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

        setState(() => _isButtonUnavailable = false);

        _sendOnMessageToBluetooth();
      }
    }
  }

  void _disconnect() async {
    _sendOffMessageToBluetooth();
    setState(() {
      _isButtonUnavailable = true;
    });

    await connection.close();
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("*" + "\r\n"));
    await connection.output.allSent;
  }


  void _sendColor(String color) async {
    connection.output.add(utf8.encode(color + "," + "\r\n"));
    await connection.output.allSent;
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("^" + "\r\n"));
    await connection.output.allSent;
  }

}