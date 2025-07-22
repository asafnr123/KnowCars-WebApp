import React from "react";
import '../styles/style.css'
import { Link } from "react-router-dom";



export default function HomePage() {
    return (
        <>
            <div className="intro">
                <h2>Know Cars</h2>
                <p>Everything you need to know</p>
                <Link to={'/cars'}><button>Learn more</button></Link>
            </div>


            <div className="usages">
                <div className="usage">
                    <p className="usage-header">Safe drive</p>
                    <p className="usage-text">Know your car’s features and get the most out of every drive</p>
                </div>

                <div className="usage">
                    <p className="usage-header">Buy with confidence</p>
                    <p className="usage-text">Know what to look for before buying your next car</p>
                </div>

                <div className="usage">
                    <p className="usage-header">Compare with clarity</p>
                    <p className="usage-text">Quickly spot differences in specs like horsepower, gear type, and more</p>
                </div>
                
            </div>
            
        </>
    )
}