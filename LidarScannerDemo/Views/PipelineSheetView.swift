import SwiftUI

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
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 600)
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
}


