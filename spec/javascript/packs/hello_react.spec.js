// Please notice that we have imported only shallow from enzyme.
// shallow improves the test performance by only rendering the component and its children,
// and it prevents rendering the entire DOM tree. However,
// you might need other rendering types, in this case, check the Enzyme’s documentation.

import React from 'react'
import { shallow } from 'enzyme'
import HelloReact from 'packs/hello_react'

describe('HelloReact component', () => {
  describe('when a name is given as a prop', () => {
    it('render Hello React!', () => {
      expect(shallow(<HelloReact name="React" />).text()).toBe('Hello React!')
    })
  })

  describe('when no name is given', () => {
    it('render Hello David!', () => {
      expect(shallow(<HelloReact />).text()).toBe('Hello David!')
    })
  })
})
