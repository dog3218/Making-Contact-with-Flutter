import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,

      home:  MyApp())
  );
}
class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Iterable<Contact> contacts = [];
  List<Contact> contact=[];
  //권한 가져오는 메소드
  getPermission() async{
  var status = await Permission.contacts.status;
  if(status.isGranted){
    print('연락처 접근 허락됨');
    contacts = await ContactsService.getContacts();

    setState(() {
      contact = contacts.toList();

    });
    /*print('첫번째가');
    print(contacts[0].displayName);
    print('인 리스트를 불러옴');*/
  }else if(status.isDenied){
    print('연락처 접근 거절됨');
    Permission.contacts.request();

  }
}

//연락처에 추가
addOne(givenName, familyName) {
    setState(() {
      var newPerson = Contact();
      newPerson.givenName =givenName;
      newPerson.familyName =familyName;
     // newPerson.displayName= name;
     ContactsService.addContact(newPerson);
    });
    getPermission();
}

  //연락처에서 지우는 메소드
  void removeOne(i){
    setState(() {
      ContactsService.deleteContact(i);
      print(i);
      print('번째 연락처가 삭제됨');
    });
  }

  updateOne(Contact info, name, phone){
    var updatePerson = info;
    setState(() {
      updatePerson.givenName = name;
      updatePerson.phones?.elementAt(0).value = phone;
      ContactsService.updateContact(updatePerson);
    });
  }
//어플 시작하면 바로 실행되는 곳
@override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder:(context){
              return DialogADD(addOne : addOne);
            });
          },
      child : const Text('+', style: TextStyle(fontSize:50),)),
      appBar: AppBar(
          title : ( Text('contacts')),
          leading: IconButton(onPressed: (){
            getPermission();
            },
              icon: Icon(Icons.contacts)),
      ),
      body: contact.isEmpty ? Center(child: Text('연락처 없음', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
              child: (ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: contact.length,
                  itemBuilder: (context, i) {
                return ListTile(
                  leading: Image.asset('assets/profile.png'),
                  title : TextButton(
                    child : Text(contact[i].displayName!),
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return DialogSelectOne(contact : contact[i]);
                      });
                  }),
                  trailing: /*Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: (){
                        showDialog(context: context, builder: (context){
                          return DialogUpdate(updateOne: updateOne, index : i );
                        });
                      },
                      icon: Icon(Icons.messenger_outline_rounded),),*/

                      ElevatedButton(
                        child: const Text('삭제'), onPressed: ((){
                        removeOne(contact[i]);
                        getPermission();
                      }),
                      ),
                    //],
                  //)
                );

              })),

          ),
        ],
      )

      );

  }
}

//'+'버튼을 눌렀을 때 나타나는 Dialog를 Custom Widget으로 만듬
class DialogADD extends StatefulWidget {
  DialogADD({Key? key, this.addOne}) : super(key: key);
  final addOne;
  var inputGivenName= TextEditingController();
  var inputFamilyName= TextEditingController();

  @override
  _DialogUIState createState() => _DialogUIState();
}

class _DialogUIState extends State<DialogADD> {
  @override
  Widget build(BuildContext context) {
    return Dialog(child : Container(
      padding :  const EdgeInsets.all(20),
      width: 500,
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Flexible(
                child: TextField(controller: widget.inputGivenName,
                  decoration:
                  const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width:1.0,
                        )
                    ),
                    icon: Icon(Icons.star),
                    hintText: '이름을 입력하세요',
                    helperText: '이름'),),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(child: TextField(controller: widget.inputFamilyName,
                  decoration:
                  InputDecoration(
                    hintText: '성을 입력하세요',
                    helperText: '성',)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('취소')) ,
              TextButton(onPressed: (){
                widget.addOne(widget.inputGivenName.text, widget.inputFamilyName.text); //3.받아온 메소드를 사용한다.
                Navigator.pop(context);
              }, child: Text('추가'))],
          ),

        ],
      ),
    ),
    );
  }
}
class DialogSelectOne extends StatefulWidget {
  const DialogSelectOne({Key? key, required this.contact}) : super(key: key);
  final Contact contact;
  @override
  _DialogUI1State createState() => _DialogUI1State();
}

class _DialogUI1State extends State<DialogSelectOne> {
  @override
  Widget build(BuildContext context) {
    return Dialog( child : Container(
    padding: const EdgeInsets.all(20),
      width: 500,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [Text('이름 : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Text(widget.contact.displayName ?? '이름없음', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ],
          ),
          Row(
            children: [Text('전화번호 : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
              Text((widget.contact.phones?.length ==0 ? '번호없음': widget.contact.phones?.elementAt(0).value.toString())!,

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold) )
              //이러면 instance of 'item' 이라고만 뜸
            ],
          ),
        ],
      ),
    ),

    );
  }
}

class DialogUpdate extends StatefulWidget {
   DialogUpdate({Key? key, this.contact, this.updateOne, this.index}) : super(key: key);
  final contact;
  final updateOne;
  final index;
  var inputGivenName = TextEditingController();
  var inputFamilyName = TextEditingController();
  @override
  _DialogUpdateState createState() => _DialogUpdateState();
}

class _DialogUpdateState extends State<DialogUpdate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding :  const EdgeInsets.all(20),
      width: 500,
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('이름'),],
          ),
          Row(
            children: [
              Flexible(
                child: TextField(controller: widget.inputGivenName,
                decoration: 
                InputDecoration(
                    hintText: '이름을 입력하세요',
                    helperText: '이름',),),
              ),
            ],
          ),Row(
            children: const [
              Text('성'),],
          ),
          Row(
            children: [
              Flexible(child: TextField(controller: widget.inputFamilyName,
                  decoration:
                  InputDecoration(
                    hintText: '성을 입력하세요',
                    helperText: '성',)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('취소')) ,
              TextButton(onPressed: (){
                widget.updateOne(widget.inputGivenName.text, widget.inputFamilyName.text); //3.받아온 메소드를 사용한다.
                Navigator.pop(context);
              }, child: Text('추가'))],
          ),

        ],
      ),
    );
  }
}

