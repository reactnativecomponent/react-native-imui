'use strict';

import React from 'react';
import ReactNative from 'react-native';

var {
  PropTypes,
  Component,
} = React;

var {
  StyleSheet,
  View,
  requireNativeComponent,
} = ReactNative;

export default class ChatInput extends Component {

  constructor(props) {
    super(props);
    this._onSendText = this._onSendText.bind(this);
    this._onSendVideo = this._onSendVideo.bind(this);
    this._onSendVoice = this._onSendVoice.bind(this);
    this._onSwitchToMicrophoneMode = this._onSwitchToMicrophoneMode.bind(this);
    this._onSwitchToActionMode = this._onSwitchToActionMode.bind(this);
    this._onSwitchToEmojiMode = this._onSwitchToEmojiMode.bind(this);
    this._onTouchEditText = this._onTouchEditText.bind(this);
    this._onEditTextChange = this._onEditTextChange.bind(this);
  }

  _onSendText(event: Event) {
    if (!this.props.onSendText) {
      return;
    }
    this.props.onSendText(event.nativeEvent.text);
  }

  _onSendVideo(event: Event) {
    if (!this.props.onSendVideo) {
      return;
    }
    this.props.onSendVideo(event.nativeEvent.mediaPath);
  }

  _onSendVoice(event: Event) {
    if (!this.props.onSendVoice) {
      return;
    }
    this.props.onSendVoice(event.nativeEvent.mediaPath, event.nativeEvent.duration);
  }
  _onSwitchToMicrophoneMode() {
    if (!this.props.onSwitchToMicrophoneMode) {
      return;
    }
    this.props.onSwitchToMicrophoneMode();
  }

  _onSwitchToActionMode() {
    if (!this.props.onSwitchToActionMode) {
      return;
    }
    this.props.onSwitchToActionMode();
  }

  _onSwitchToEmojiMode() {
    if (!this.props.onSwitchToEmojiMode) {
      return;
    }
    this.props.onSwitchToEmojiMode();
  }

  _onTouchEditText() {
    if (!this.props.onTouchEditText) {
      return;
    }
    this.props.onTouchEditText();
  }
  _onEditTextChange(event: Event) {
    if (!this.props.onEditTextChange) {
      return;
    }
    this.props.onEditTextChange(event.nativeEvent.text);
  }

  render() {
    return (
      <RCTChatInput 
          {...this.props} 
          onSendText={this._onSendText}
          onSendVideo={this._onSendVideo}
          onSendVoice={this._onSendVoice}
          onSwitchToMicrophoneMode={this._onSwitchToMicrophoneMode}
          onSwitchToActionMode={this._onSwitchToActionMode}
          onSwitchToEmojiMode={this._onSwitchToEmojiMode}
          onTouchEditText={this._onTouchEditText}
          onEditTextChange={this._onEditTextChange}
      />
    );
  }

}

ChatInput.propTypes = {
  menuContainerHeight: PropTypes.number,
  isDismissMenuContainer: PropTypes.bool,
  onSendVideo: PropTypes.func,
  onSendVoice: PropTypes.func,
  onSwitchToMicrophoneMode: PropTypes.func,
  onSwitchToActionMode: PropTypes.func,
  onSwitchToEmojiMode: PropTypes.func,
  onTouchEditText: PropTypes.func,
  onEditTextChange: PropTypes.func,
  ...View.propTypes
};

var RCTChatInput = requireNativeComponent('RCTChatInput', ChatInput);