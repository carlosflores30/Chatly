//
//  ExtenstionChatController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//

import UIKit
import SDWebImage
import ImageSlideshow
import AVFoundation

extension ChatViewController{
    
    @objc func handleCamera(){
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
        print("Camara")
    }
    
    @objc func handleGallery(){
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
        print("Galeria")
    }
    
    @objc func handleCurrentLocation(){
        FLocationManager.shared.start { info in
            guard let lat = info.latitude else {return}
            guard let lng = info.longitude else {return}
            
            self.uploadLocation(lat: "\(lat)", lng: "\(lng)")
            FLocationManager.shared.stop()
        }
    }
    
    @objc func handleGoogleMap(){
        let controller = ChatMapVC()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func uploadLocation(lat: String, lng: String){
        let locationURL = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)"
        
        self.showLoader(true)
        MessageServices.fetchSingleRecentMsg(otherUser: otherUser) { unReadCount in
            MessageServices.uploadMessage(locationURL: locationURL,currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount + 1) { error in
                self.showLoader(false)
                
                if let error = error {
                    print("error \(error.localizedDescription)")
                    return
                }
            }
        }
        
    }
}

extension ChatViewController: ChatMapVCDelegate{
    func didTapLocation(lat: String, lng: String) {
        navigationController?.popViewController(animated: true)
        print("Ubicación seleccionada: Lat: \(lat), Lng: \(lng)")
        uploadLocation(lat: lat, lng: lng)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //
        dismiss(animated: true) {
            guard let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String else {return}
            
            if mediaType == "public.image"{
                guard let image = info[.editedImage] as? UIImage else {return}
                self.uploadImage(withImage: image)
            }
            else{
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {return}
                self.uploadVideo(withVideoURL: videoURL)
            }
        }
    }
}

extension ChatViewController{
    func uploadImage(withImage image: UIImage){
        showLoader(true)
        FileUploader.uploadImage(image: image) { imageURL in
            MessageServices.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadMsgCount in
                MessageServices.uploadMessage(imageURL: imageURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadMsgCount + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("error \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func uploadVideo(withVideoURL url: URL){
        showLoader(true)
        FileUploader.uploadVideo(url: url) { videoURL in
            MessageServices.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadMsgCount in
                MessageServices.uploadMessage(videoURL: videoURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadMsgCount + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("error \(error.localizedDescription)")
                        return
                    }

                }
            }
        } failure: { error in
                print("error: \(error.localizedDescription)")
                return
        }

    }
}

extension ChatViewController: ChatCellDelegate{
    
    func cell(wantToPlayVideo cell: ChatCell, videoURL: URL?) {
        guard let videoURL = videoURL else {return}
        let controller = VideoPlayerVC(videoURL: videoURL)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantToShowImage cell: ChatCell, imageURL: URL?) {
        let slideShow = ImageSlideshow()
        guard let imageURL = imageURL else {return}
        
        SDWebImageManager.shared.loadImage(with: imageURL, progress: nil){image,_,_,_,_,_ in
            guard let image = image else {return}
            
            slideShow.setImageInputs([
                ImageSource(image: image)
            ])
            
            slideShow.delegate = self as? ImageSlideshowDelegate
            
            let controller = slideShow.presentFullScreenController(from: self)
            controller.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
    func playAudio(from url: URL, in cell: ChatCell) {
        // Inicializa el AVPlayer con la URL remota
        audioPlayer = AVPlayer(url: url)
        
        currentPlayingCell = cell
        
        // Reproduce el audio
        audioPlayer?.play()
        
        // Agregar un observador para escuchar cuando la reproducción termine, si lo deseas
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
    }

    @objc func audioDidFinishPlaying() {
        print("El audio ha terminado de reproducirse.")
        
        currentPlayingCell?.updateAudioButton(isPlaying: true)
        
        currentPlayingCell = nil
        // Aquí puedes hacer algo cuando termine la reproducción, como actualizar la interfaz de usuario.

    }
    func stopAudio() {
        audioPlayer?.pause() // Detener la reproducción
        audioPlayer = nil // Liberar el recurso
        print("Audio detenido.")
    }
    
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool) {
        if isPlay{
            guard let audioURL = audioURL else {
                print("Error: audioURL es nulo")
                return
            }
            playAudio(from: audioURL, in: cell)
        } else {
            stopAudio()
        }
        
        cell.updateAudioButton(isPlaying: isPlay)
    }
    
    func cell(wantToOpenGoogleMap cell: ChatCell, locationURL: URL?) {
        guard let googleURLApp = URL(string: "comgooglemaps://") else {return}
        guard let locationURL = locationURL else {return}
        
        if UIApplication.shared.canOpenURL(googleURLApp){
            UIApplication.shared.open(locationURL)
        } else {
            UIApplication.shared.open(locationURL, options: [:])
        }
    }
}
