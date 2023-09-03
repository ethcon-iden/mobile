import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../resource/kConstant.dart';
import '../controller/state_controller.dart';

class Web3Credentials {
  Web3Credentials();

  static Web3Credentials instance = Web3Credentials();

  String? privateKey;
  SSS sss = SSS();

  String generatePrivateKey() {
    final random = Random.secure();

    Uint8List? pKeyUint8List;
    while (true) {
      EthPrivateKey key = EthPrivateKey.createRandom(random);
      final pk = key.privateKey;
      if (pk.length == 32) {
        pKeyUint8List = pk;
        break;
      }
    }

    final pKeyHex = bytesToHex(pKeyUint8List);
    print('---> private key hex: $pKeyHex | ${pKeyHex.length}');
    privateKey = pKeyHex;
    service.pKey.value = pKeyHex;
    return pKeyHex;
  }

  String getAddress(String privateKey) {
    String out;
    if (privateKey.isNotEmpty) {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final addr = credentials.address;
      final addrHex = addr.hexEip55;
      print('---> address: $addrHex | ${addrHex.length}');
      out = addrHex;
    } else {
      out = '';
    }
    return out;
  }

  // Future<String> getSignature(SignTransaction signTransaction) async {
  //   final String? pKey = await DogeSecureStorage.instance.getKey(kStorageKey.privateKey);
  //   print('---> pKey: $pKey | ${pKey!.length}');
  //   final credentials = EthPrivateKey.fromHex(pKey);
  //
  //   final maxFeePerGas = signTransaction.maxFeePerGas!.split('0x')[1];
  //   final bigIntMaxFeePerGas = BigInt.parse(maxFeePerGas, radix: 16);
  //   final maxPriorityFeePerGas = signTransaction.maxPriorityFeePerGas!.split('0x')[1];
  //   final bigIntMaxPriorityFeePerGas = BigInt.parse(maxPriorityFeePerGas, radix: 16);
  //
  //   print('---> get signature > maxFeePerGas > hex: $maxFeePerGas | BigInt: $bigIntMaxFeePerGas');
  //
  //   signTransaction.printOut();
  //
  //   // if (sender != null) 'from': sender.hex,
  //   // if (to != null) 'to': to.hex,
  //   // if (amountOfGas != null) 'gas': '0x${amountOfGas.toRadixString(16)}',
  //   // if (gasPrice != null) 'gasPrice': '0x${gasPrice.getInWei.toRadixString(16)}',
  //   // if (maxPriorityFeePerGas != null) 'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.getInWei.toRadixString(16)}',
  //   // if (maxFeePerGas != null) 'maxFeePerGas': '0x${maxFeePerGas.getInWei.toRadixString(16)}',
  //   // if (value != null) 'value': '0x${value.getInWei.toRadixString(16)}',
  //   // if (data != null) 'data': bytesToHex(data, include0x: true),
  //
  //
  //   final Transaction transaction = Transaction(
  //     from: EthereumAddress.fromHex(signTransaction.from!),
  //     to: EthereumAddress.fromHex(signTransaction.to!),
  //     nonce: signTransaction.nonce,
  //     maxGas: signTransaction.gasLimit,
  //     data: Uint8List.fromList(signTransaction.data!.codeUnits),
  //     maxFeePerGas: EtherAmount.inWei(bigIntMaxFeePerGas),
  //     maxPriorityFeePerGas: EtherAmount.inWei(bigIntMaxPriorityFeePerGas),
  //     value: EtherAmount.inWei(BigInt.parse(signTransaction.value!))
  //   );
  //
  //   var client = Web3Client('', Client());
  //   final signHex = await client.getSignTransaction(
  //       credentials,
  //       transaction,
  //       chainId: signTransaction.chainId
  //   );
  //   print('---> get signature using client > hex: $signHex');
  //
  //   return signHex;
  // }

  void infoFromW3A() async {
    final credentials = EthPrivateKey.fromHex(privateKey!);
    print('---> w3a address: ${credentials.address.hexEip55} | ${credentials.address.hexEip55.length}');
  }

  List<String> sharingKey(String pKey) {
    // SSS sss = SSS();
    // String origin = '0e4c23829b2510332ef269371e9022c0655dc01674361ece2504d1be9ecccc1c';
    print('---> private key split and combine using Shamir\'s secret sharing');

    List<String> arr = sss.create(2, 3, pKey, true); // true -> 88 bytes, false -> 128 bytes
    print('---> split1: ${arr[0]} | ${arr[0].length}');
    print('---> split2: ${arr[1]} | ${arr[1].length}');
    print('---> split3: ${arr[2]} | ${arr[2].length}');

    return arr;   // length: 3
  }

  String restoringKey(List<String> keyShares) {
    var pKey = sss.combine([keyShares[0], keyShares[1]], true);
    print("combine [0,1]: $pKey | ${pKey.length}");
    return pKey;
  }

  // void _sssTest(String pKey) {
  //   // SSS sss = SSS();
  //   // String origin = '0e4c23829b2510332ef269371e9022c0655dc01674361ece2504d1be9ecccc1c';
  //   print('---> private key split and combine using Shamir\'s secret sharing');
  //
  //   List<String> arr = sss.create(2, 3, pKey, true); // true -> 88 bytes, false -> 128 bytes
  //   print('---> split1: ${arr[0]} | ${arr[0].length}');
  //   print('---> split2: ${arr[1]} | ${arr[1].length}');
  //   print('---> split3: ${arr[2]} | ${arr[2].length}');
  //
  //   var s1 = sss.combine([arr[0], arr[1]], true);
  //   print("combine [0,1]: $s1 | ${s1.length}");
  //
  //   var s2 = sss.combine([arr[1], arr[2]], true);
  //   print("combine [1,2]: $s2 | ${s2.length}");
  //
  //   var s3 = sss.combine([arr[0], arr[2]], true);
  //   print("combine [0,2]: $s3 | ${s3.length}");
  //
  //   if (pKey == s1 && pKey == s2 && pKey == s3) {
  //     print('---> origin vs combine keys are all perfect matched.');
  //   }
  // }

  void getSigning(String addrHex) {
    // final keyUint8List = EthPrivateKey().encodedPublicKey;
    // print('---> get signing > keyUint8List address: ${keyUint8List.address}');

    // final credentials = Credentials().signToUint8List()
    // print('---> get signing > credentials address: ${credentials.address}');
    // print('---> get signing > credentials: ${credentials.privateKey}');
  }

  // void testSigning() {
  //   // 데이터 생성
  //   var data = {
  //     'nonce': '0x1',
  //     'gasPrice': '0x09184e72a000',
  //     'gasLimit': '0x2710',
  //     'to': '0x123...',
  //     'value': '0x456...',
  //     'data': '',
  //   };
  //   // 데이터를 RLP 인코딩
  //   // var rlpEncodedData = rlpEncode(data);
  //   var rlpEncodeData = Rlp.encode(data);
  //   String rlpEncodeDataHex = bytesToHex(rlpEncodeData);
  //
  //   // 프라이빗 키 생성 및 서명
  //   var privateKey = 'd5a6...';
  //   var sign = signWithPrivateKey(rlpEncodeDataHex, privateKey);
  //   // Raw Transaction Hash 생성
  //   var rawTransactionHash = sha3_256.convert(hexDecode(sign)).toString();
  //   print('RLP Encoded Data: $rlpEncodedData');
  //   print('Signature: $sign');
  //   print('Raw Transaction Hash: $rawTransactionHash');
  //
  //   // String rlpEncode(dynamic obj) {
  //   //   // RLP 인코딩을 위한 로직 구현
  //   //   // ...
  //   // }
  //
  //   String signWithPrivateKey(String data, String privateKey) {
  //     // var key = RSAPrivateKey.fromString(privateKey);
  //     var k = RSAPrivateKey();
  //
  //     var signer = RS256Signer(key);
  //     var signature = signer.signBytes(hexDecode(data));
  //     return base64.encode(signature);
  //   }
  //   List<int> hexDecode(String hexString) {
  //     return List.generate(hexString.length ~/ 2, (i) {
  //       return int.parse(hexString.substring(i * 2, i * 2 + 2), radix: 16);
  //     });
  //   }
  // }
}