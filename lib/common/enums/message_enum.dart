// enum MessageEnum {
//   text('text'),
//   image('image'),
//   location('location'),
//   video('video');
//
//   const MessageEnum(this.type);
//   final String type;
// }
//
// // Using an extension
// // Enhanced enums
//
// extension ConvertMessage on String {
//   MessageEnum toEnum() {
//     switch (this) {
//       case 'location':
//         return MessageEnum.location;
//       case 'image':
//         return MessageEnum.image;
//       case 'text':
//         return MessageEnum.text;
//       case 'video':
//         return MessageEnum.video;
//       default:
//         return MessageEnum.text;
//     }
//   }
// }
