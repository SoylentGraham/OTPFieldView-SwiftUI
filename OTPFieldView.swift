//
//  OTPFieldView.swift
//  OTP Field View
//
//  Created by Jayant on 06/10/23.
//


import SwiftUI
import Combine


// A SwiftUI view for entering OTP (One-Time Password).
public struct OTPFieldView: View 
{
    @FocusState private var pinFocusState: FocusPin?
    @Binding private var otp: String
    @State private var pins: [String]
    
    var numberOfFields: Int

	//	this _could_ be done in the binding by parent, in which case
	//	we need to re-initialise pins after setting the binding
	var sanitiseOtp : ((String) -> String)
	
	//	todo: default to OS text input colours
	var foregroundColor : Color
	//	todo: make this a view
	var backgroundColor : Color
	
    
    enum FocusPin: Hashable {
        case pin(Int)
    }
    
	public init(numberOfFields: Int, otp: Binding<String>,foregroundColor:Color=Color.black,backgroundColor:Color=Color.white,sanitiseOtp:((String) -> String)?=nil) 
	{
        self.numberOfFields = numberOfFields
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
        self._otp = otp
        self._pins = State(initialValue: Array(repeating: "", count: numberOfFields))
		self.sanitiseOtp = sanitiseOtp ?? OTPFieldView.defaultSanitiseOtp
    }

	static func defaultSanitiseOtp(_ otp:String) -> String
	{
		return otp
	}
	
    
    public var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<numberOfFields, id: \.self) 
			{
				index in
                TextField("", text: $pins[index])
					.frame(maxWidth: .infinity,maxHeight:.infinity)
					.textFieldStyle(PlainTextFieldStyle())	//	remove default OS styling
					.foregroundStyle(foregroundColor)
					.background(
						RoundedRectangle(cornerRadius: 4)
							.fill(backgroundColor)
							.stroke(Color.gray, lineWidth: 1)
					)
                    .modifier(OtpModifier(pin: $pins[index]))
                    .onChange(of: pins[index]) 
					{ 
						newVal in
                        if newVal.count == 1 {
                            if index < numberOfFields - 1 {
                                pinFocusState = FocusPin.pin(index + 1)
                            } else {
                                // Uncomment this if you want to clear focus after the last digit
                                // pinFocusState = nil
                            }
                        }
                        else if newVal.count == numberOfFields, let intValue = Int(newVal) {
                            // Pasted value
                            otp = newVal
                            updatePinsFromOTP()
                            pinFocusState = FocusPin.pin(numberOfFields - 1)
                        }
                        else if newVal.isEmpty {
                            if index > 0 {
                                pinFocusState = FocusPin.pin(index - 1)
                            }
                        }
                        updateOTPString()
                    }
                    .focused($pinFocusState, equals: FocusPin.pin(index))
                    .onTapGesture {
                        // Set focus to the current field when tapped
                        pinFocusState = FocusPin.pin(index)
                    }
            }
        }
        .onAppear {
            // Initialize pins based on the OTP string
            updatePinsFromOTP()
        }
    }
    
    private func updatePinsFromOTP() {
        let otpArray = Array(otp.prefix(numberOfFields))
        for (index, char) in otpArray.enumerated() {
            pins[index] = String(char)
        }
    }
    
    private func updateOTPString() {
        otp = pins.joined()
    }
}

struct OtpModifier: ViewModifier {
    @Binding var pin: String
    
    var textLimit = 1
    
    func limitText(_ upper: Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
#if canImport(UIKit)
            .keyboardType(.numberPad)
#endif
            .onReceive(Just(pin)) { _ in limitText(textLimit) }
            .frame(width: 40, height: 48)
            .font(.system(size: 14))
 
    }
}


#Preview 
{
	/*@Previewable*/ @State var otp : String = ""

	VStack(alignment: .leading, spacing: 8) 
	{
		Text("VERIFICATION CODE")
			.foregroundColor(Color.gray)
			.font(.system(size: 12))
		OTPFieldView(numberOfFields: 5, otp: .constant("54321"))
			.previewLayout(.sizeThatFits)
	}
}



