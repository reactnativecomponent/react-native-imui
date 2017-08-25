/**
 * Created by dowin on 2017/8/3.
 */

import React, {Component, PropTypes} from 'react';
import {View, requireNativeComponent,NativeModules} from 'react-native';
const { RecordView } = NativeModules;

export default class RCTTimerTip extends Component {

    render() {
        return (
            <TimerTip
                {...this.props}
            />);
    }
}
RCTTimerTip.propTypes = {
    ...View.propTypes,
    level:PropTypes.string,
    time:PropTypes.string,
    numFontSize:PropTypes.string,
    status:PropTypes.string,//0正在录音，1，取消发送，2，录音时间过短
};
const TimerTip = requireNativeComponent('TimerTip', RCTTimerTip);