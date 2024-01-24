import SwiftUI
import SceneKit

@available(iOS 16.4, *)
struct StateModelViewer: View {
    @Binding var modelURL: URL?
    

    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    @State var showMeasureSheet = false
    @State var measuredDistance = 0.0
    @State var isMeasuredFirstPoint = false
    @State var isReturnToInit = false
    
    @State var showPipelineSheet = false
    @State var isPipelineDrawFirstPoint = false
    @State var isPipelineReturnOneStep = false
    @State var pipelineExportedImage:Image?
    @State var isExportImage = false
    
    @State var isModelLoading = true;
    
    
    @State private var viewKey = UUID()
    var body: some View {
        ZStack {
            if let url = modelURL {
                ObjModelMeasureView(objURL: url, isMeasureActive: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit, isPipelineActive: $showPipelineSheet, isPipelineDrawFirstPoint: $isPipelineDrawFirstPoint, isPipelineReturnOneStep: $isPipelineReturnOneStep, isExportImage: $isExportImage, exportedImage: $pipelineExportedImage, isModelLoading: $isModelLoading)
                    .frame(width: width, height: height)
                    .id(viewKey)  // Use the key here
            } else {
                Text(NSLocalizedString("No model to display", comment: ""))
            }
            ToolBarView()
            if isModelLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    .foregroundColor(.black)
                    .scaleEffect(1)
                    
            }
        }
        .onChange(of: modelURL) { _ in
            viewKey = UUID()  // Change the key to force a refresh
        }
        .sheet(isPresented: $showMeasureSheet) {
            MeasureSheetView(isPresented: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit) // Your custom bottom sheet view
                .presentationDetents([
                    .height(130),   // 100 points
                ])
                .presentationCornerRadius(0)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(130)))
        }
        .sheet(isPresented: $showPipelineSheet) {
            PipelineSheetView(
                isPresented: $showPipelineSheet,
                isDrawFirstPoint: $isPipelineDrawFirstPoint,
                isReturnOneStep: $isPipelineReturnOneStep,
                exportedImage: $pipelineExportedImage,
                isExportImage: $isExportImage
            )
            .presentationDetents(Set(determineSheetHeight()))
            .presentationCornerRadius(0)
            .presentationBackgroundInteraction(.enabled(upThrough: determineSheetHeight().first!))
        }
    }
    
    private func determineSheetHeight() -> [PresentationDetent] {
        if pipelineExportedImage != nil {
            // Return a larger height when there is an exported image
            return [.large] // Adjust the height as needed
        } else {
            // Return the default height when there is no image
            return [.height(130)] // Default height
        }
    }
    
    
    private func ToolBarView() -> some View{
        VStack{
            Spacer()
            HStack(){
                Spacer()
                measureButtonView()
                Spacer()
                pipelineButtonView()
                Spacer()
            }
            .padding(.bottom,20)
        }
    }
    
    private func measureButtonView() -> some View {
        VStack {
            Button(action: {
                showMeasureSheet.toggle()
            }) {
                Image(systemName: "ruler")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.black.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Measure", comment: "measure"))
                .foregroundColor(.black)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
    private func pipelineButtonView() -> some View {
        VStack {
            Button(action: {
                showPipelineSheet.toggle()
            }) {
                Image(systemName: "skew") // or 􁤓
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.black.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Pipeline", comment: "measure"))
                .foregroundColor(.black)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
}
