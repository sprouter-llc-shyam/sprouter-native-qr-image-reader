import NativeModule from "./NativeSprouterNativeQrImageReader";

export function readQRFromImage(source: string) {
  return NativeModule.readQRFromImage(source);
}
