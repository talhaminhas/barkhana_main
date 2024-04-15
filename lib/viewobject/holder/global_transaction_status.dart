
import 'dart:ffi';

class GlobalTransactionStatus {
  GlobalTransactionStatus({
    //this.id,
    this.status,
    this.error
  });
  //String? id;
  Bool? status;
  String? error;


  GlobalTransactionStatus? fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return GlobalTransactionStatus(
        //id: dynamicData['id'],
          status: dynamicData['status'],
          error: dynamicData['error']
      );
    } else {
      return null;
    }
  }


}
