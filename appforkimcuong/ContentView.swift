import SwiftUI
import AVFoundation
struct ContentView: View {
    var body: some View {
        CameraView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CameraView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.5)
                .padding(.top, 80)
            
            VStack {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("10 người bạn")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    .overlay(
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            .offset(x: 30, y: -10)
                    )
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
                
                Button(action: { cameraModel.takePhoto() }) {
                    Circle()
                        .strokeBorder(Color.yellow, lineWidth: 3)
                        .background(Circle().fill(Color.gray))
                        .frame(width: 70, height: 70)
                }
                .padding(.bottom, 40)
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 20)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear { cameraModel.startSession() }
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var output = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        startSession()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.beginConfiguration()
            
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    }
                    
                    if self.session.canAddOutput(self.output) {
                        self.session.addOutput(self.output)
                    }
                    
                    self.session.commitConfiguration()
                    self.session.startRunning()
                } catch {
                    print("Error setting up camera: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        print("Photo captured successfully")
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
