import SwiftUI
import UIKit

struct PipelineSheetView: View {
    @Binding var isPresented: Bool
    @Binding var isDrawFirstPoint: Bool
    @Binding var isReturnOneStep: Bool
    @Binding var exportedImage: Image? // Binding for the exported image
    @Binding var isExportImage: Bool
    var body: some View {
        VStack {
            // Header with buttons
            headerView
            Spacer()
            // Image display area
            if let image = exportedImage {
                VStack{
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 600)
                    Button(action: {
                        if let uiImage = convertToUIImage(image) {
                            ImageSaver.shared.saveToPhotoLibrary(image: uiImage)
                        }
                        isPresented = false
                    }) {
                        HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.title2)
                                Text("保存至相册")
                                    .font(.title2)
                        }
                        .frame(maxWidth: 200)
                            .foregroundColor(.white)
                            .padding(.vertical,20)
                            .background(Color.green)
                            .cornerRadius(16)
                    }
                }
            } else if(isDrawFirstPoint) {
                Button(action: {
                    isExportImage = true;
                }) {
                    Text(NSLocalizedString("Export pipeline", comment: ""))
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(!isDrawFirstPoint)
            }
            else{
                Text(NSLocalizedString("tap pipeline to measure", comment: ""))
            }
            Spacer()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding()
            }
            .padding(.horizontal, 10)
            Spacer()
            Text(NSLocalizedString("Pipeline draw", comment: ""))
                .font(.title2)
            Spacer()
            Button(action: {
                if((exportedImage == nil)){
                    isReturnOneStep = true
                }
                else{
                    exportedImage = nil
                }
            }) {
                Image(systemName: "return")
                    .foregroundColor(isDrawFirstPoint ? .white : .gray)
                    .font(.title2)
                    .padding()
            }
            .disabled(!isDrawFirstPoint)
            .padding(.horizontal, 10)
        }
    }
    
    private func convertToUIImage(_ image: Image) -> UIImage? {
        // Create a UIHostingController with the Image
        let controller = UIHostingController(rootView: image.resizable())
        let view = controller.view

        // Set the size to the screen size
        let targetSize = UIScreen.main.bounds.size
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        // Create the renderer with the target size
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    
}

class ImageSaver: NSObject {
    static let shared = ImageSaver()
    
    private override init() {}
    
    func saveToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error case
            return
        } else {
            // Image was saved successfully
            return;
        }
    }
}





