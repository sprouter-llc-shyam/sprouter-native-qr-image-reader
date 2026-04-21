import { TurboModuleRegistry, type TurboModule } from "react-native";

export interface Spec extends TurboModule {
  readQRFromImage(source: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  "SprouterNativeQrImageReader"
);
