enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  file('file'),
  link('link');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'file':
        return MessageEnum.file;
      case 'link':
        return MessageEnum.link;
      case 'video':
        return MessageEnum.video;
      default:
        return MessageEnum.text;
    }
  }
}
