//
//  ViewController.swift
//  iOS-multipartAPI
//
//  Created by Jack Wong on 2018/09/20.
//  Copyright © 2018 Jack Wong. All rights reserved.
//

import Alamofire
import UIKit
import Photos

final class ViewController: UIViewController {
    
    private let imagePicker = UIImagePickerController()
    var image = UIImage()
    var imageData = Data()
    var imagePath = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    @IBAction func getPhoto(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func post(_ sender: Any) {
        print(imageData)
        upload(imageData: imageData, parameter:["file": image], onCompletion: { result in
            print("result STring", result)
        }) { err in
            print("erororor", err)
        }
    }
    
    private func upload(imageData: Data?, parameter: [String: Any],onCompletion: ((String?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil) {
        let url = "http://18.222.190.104:8080/api/2.0.0/images/uploadimage"
        let headers: HTTPHeaders = [
            "Authorization": "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsicmVzb3VyY2UiXSwidXNlcl9uYW1lIjoiai53b25nQHN0LXZlbnR1cmVzLmpwIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIl0sImV4cCI6MTUzNzY3ODEyMywianRpIjoiMzAwOGRlMWUtYTMxMi00YTNiLWE3NDgtYjYzMWMyOTI1YjVlIiwiZW1haWwiOiJqLndvbmdAc3QtdmVudHVyZXMuanAiLCJjbGllbnRfaWQiOiJhbmEifQ.GGQqervwSCTb_kyAW569qIK6Eck9_F5_hLuXqkYr7tA",
           "Content-type": "multipart/form-data"
        ]
       
        Alamofire.upload(multipartFormData:{ multipartFormData in

//            for (key, value) in parameter {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//             }
                if let data = imageData {
                    multipartFormData.append(data, withName: "file", fileName: "image.png", mimeType: "image/png")
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
                switch result {
                case .success(request: let uploadReq, streamingFromDisk: _, streamFileURL: _):
                    uploadReq.responseString(completionHandler: { response in
                        print("success", response)
                        if let err = response.error {
                            onError?(err)
                            return
                        }
                        onCompletion?(nil)
                    })
                case .failure(let error):
                    print("error inuplaod", error)
                    onError?(error)
                }
        }
    }

}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        image = originalImage
        let url = info[UIImagePickerControllerImageURL] as? URL
        imagePath = (url?.absoluteString)!
        let urlpath = URL(fileURLWithPath: imagePath)
        print("imagePath", imagePath, urlpath)
        if let data = UIImageJPEGRepresentation(originalImage, 1) {
            imageData = data
        }
        dismiss(animated: true, completion: nil)
    }
}
