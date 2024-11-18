// v3  working

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];
  String inputts="";
  var textedcontroller = new TextEditingController();
  var statuss = new WidgetStatesController();


  late StreamSubscription<List<int>> _lastValueSubscription;

  late TextEditingController textEditcontroller;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  Future onWritePressed() async {
    try {
      // await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
      //List<int> lan = utf8.encode("B"+textedcontroller.text+";") ;
      List<int> lan = utf8.encode(":"+textedcontroller.text+"\n") ;
      await c.write(lan, withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);

      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  //We have to use this function to send some data and receive reply
  Future onWriteRead() async {
    try {
      // await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
      //List<int> lan = utf8.encode("A;") ;
      //following two lines are used to send ascii data
      List<int> lan = utf8.encode(":"+textedcontroller.text+"\n") ;
      await c.write(lan, withoutResponse: c.properties.writeWithoutResponse);

      //following 3 lines are used to send hex data
      //List<int> lan = textedcontroller.text.split('').map(int.parse).toList() ;
      //String hexValue=lan.map((e) => e.toRadixString(16)).join();
      //List<int> hexList=hexValue.split('').map(int.parse).toList();
      //print("Preparing Data for transmission");
      //print(textedcontroller.text);
      //print(textedcontroller.text.split('')[1]);
      //List<int> finalData = textedcontroller.text.split('').map(int.parse).toList();
      //finalData.add(10);
      //finalData.add(13);
      //finalData.add(int.parse('\n'));
      //print("Data for trasmission");
      //for(int i=0;i<hexList.length;i++){
      //  print(hexList[i]);
      //}
      //List<int> x=[0x3B,0x00,0x01,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x06,0x05,0x04,0x0A,0x0D];

      //await c.write(x, withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    //String data = utf8.decode(_value);
    // inputts=textedcontroller.text;
    // ascii
      String data = String.fromCharCodes(_value);
    // return Text(data, style: TextStyle(fontSize: 13, color: Colors.black));
    // return Text(_value.toString(), style: TextStyle(fontSize: 13, color: Colors.black));

    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,\c
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data, style: TextStyle(fontSize: 13, color: Colors.black)),
        Text(_value.toString(), style: TextStyle(fontSize: 13, color: Colors.black)),
      ],
    );

  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return Row(
      children: [
        TextButton(
            child: Text(withoutResp ? "WriteNoResp" : "Write"),
            onPressed: () async {
              await onWritePressed();
              if (mounted) {
                setState(() {});
              }
            }),
        TextButton(onPressed: () async{
          onWriteRead();
        }, child: Text("Read"))
      ],
    );
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        // enabled: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            SizedBox(height: 10,),
            Container(width: 150, height: 25, child: TextField(controller: textedcontroller, decoration: InputDecoration(hintText: "Text to write"),)),
            buildValue(context),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles,
    );
  }
}
